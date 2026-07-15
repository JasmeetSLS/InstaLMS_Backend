// video_emotion.js
// ================= AWS SDK v3 IMPORTS =================
const {
    RekognitionClient,
    DetectFacesCommand
} = require('@aws-sdk/client-rekognition');

const { S3Client } = require('@aws-sdk/client-s3');

// ================= OTHER IMPORTS =================
const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');
const util = require('util');
const execPromise = util.promisify(exec);
const { GoogleGenerativeAI } = require('@google/generative-ai');

// ================= CONFIG =================
const AWS_KEY = process.env.AWS_ACCESS_KEY_ID;
const AWS_SECRET = process.env.AWS_SECRET_ACCESS_KEY;
const AWS_REGION = process.env.AWS_REGION || 'us-east-1';

// Gemini API Key (optional)
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || '';

// ================= AWS SDK v3 CLIENTS =================
const rekognitionClient = new RekognitionClient({
    region: AWS_REGION,
    credentials: {
        accessKeyId: AWS_KEY,
        secretAccessKey: AWS_SECRET
    }
});

const s3Client = new S3Client({
    region: AWS_REGION,
    credentials: {
        accessKeyId: AWS_KEY,
        secretAccessKey: AWS_SECRET
    }
});

// ================= GEMINI AI CLIENT (optional) =================
let genAI = null;
try {
    if (GEMINI_API_KEY && GEMINI_API_KEY !== '') {
        genAI = new GoogleGenerativeAI(GEMINI_API_KEY);
        console.log('✅ Gemini AI client initialized');
    } else {
        console.log('⚠️ Gemini API key not configured, using fallback analysis');
    }
} catch (error) {
    console.log('⚠️ Gemini AI initialization failed:', error.message);
}

// ================= FFMPEG PATH DETECTION =================
function findFFmpegPath() {
    if (process.env.FFMPEG_PATH) {
        console.log(`🔧 Using FFMPEG_PATH from environment: ${process.env.FFMPEG_PATH}`);
        return process.env.FFMPEG_PATH;
    }
    return 'ffmpeg';
}

let ffmpegPath = findFFmpegPath();
console.log(`📂 FFmpeg path: ${ffmpegPath}`);

// ================= FFMPEG HELPER FUNCTIONS =================

async function checkFFmpeg(ffmpegPath) {
    console.log(`🔍 Checking FFmpeg at: ${ffmpegPath}`);
    try {
        const cmd = process.platform === 'win32' ? `"${ffmpegPath}" -version` : `${ffmpegPath} -version`;
        await execPromise(cmd);
        console.log('✅ FFmpeg is accessible');
        return true;
    } catch (error) {
        console.error('❌ FFmpeg check failed:', error.message);
        return false;
    }
}

async function executeFFmpeg(ffmpegPath, videoPath, framePattern, maxFrames = 30) {
    const isAvailable = await checkFFmpeg(ffmpegPath);
    if (!isAvailable) {
        ffmpegPath = findFFmpegPath();
        console.log(`🔄 Retrying with found path: ${ffmpegPath}`);
        const retryAvailable = await checkFFmpeg(ffmpegPath);
        if (!retryAvailable) {
            throw new Error(`FFmpeg not found. Please install FFmpeg and ensure it's in PATH.`);
        }
    }

    return new Promise((resolve, reject) => {
        const quotedVideoPath = process.platform === 'win32' ? `"${videoPath}"` : videoPath;
        const quotedFramePattern = process.platform === 'win32' ? `"${framePattern}"` : framePattern;
        const quotedFFmpeg = process.platform === 'win32' ? `"${ffmpegPath}"` : ffmpegPath;

        const command = `${quotedFFmpeg} -i ${quotedVideoPath} -vf fps=1 -vsync 0 -vframes ${maxFrames} ${quotedFramePattern}`;

        console.log(`🎬 Executing FFmpeg command: ${command}`);

        exec(command, {
            maxBuffer: 1024 * 1024 * 10,
            windowsHide: true
        }, (error, stdout, stderr) => {
            if (error) {
                const frameDir = path.dirname(framePattern);
                if (fs.existsSync(frameDir)) {
                    const files = fs.readdirSync(frameDir).filter(f => f.endsWith('.jpg'));
                    if (files.length > 0) {
                        console.log(`⚠️ FFmpeg exited with error but ${files.length} frames were created`);
                        resolve(stdout);
                        return;
                    }
                }
                console.error('❌ FFmpeg error:', error.message);
                console.error('Stderr:', stderr);
                reject(new Error(`FFmpeg failed: ${error.message}\n${stderr}`));
            } else {
                console.log('✅ FFmpeg extraction complete');
                resolve(stdout);
            }
        });
    });
}

// ================= AWS Rekognition =================
async function detectFaces(imageBuffer) {
    try {
        const command = new DetectFacesCommand({
            Image: { Bytes: imageBuffer },
            Attributes: ['ALL']
        });
        const response = await rekognitionClient.send(command);
        return response;
    } catch (error) {
        console.error('Rekognition error:', error.message);
        throw error;
    }
}

// ================= GEMINI AI FUNCTIONS (optional) =================
async function analyzeWithGemini(emotionData, faceExpression, frameCount) {
    if (!genAI) {
        console.log('⚠️ Gemini AI not available, using fallback analysis');
        return generateFallbackAnalysis(emotionData, faceExpression, frameCount);
    }

    try {
        const model = genAI.getGenerativeModel({ model: "gemini-2.0-flash" });
        const prompt = `
        Analyze the following emotion data from a video analysis:
        Emotion Averages:
        ${JSON.stringify(emotionData, null, 2)}
        Face Expression Distribution:
        ${JSON.stringify(faceExpression, null, 2)}
        Number of faces detected: ${frameCount}
        Provide JSON with keys: summary, insights, emotionalState, confidenceLevel
        `;
        console.log('🤖 Sending request to Gemini AI...');
        const result = await model.generateContent(prompt);
        const response = await result.response;
        const text = response.text();
        try {
            const jsonMatch = text.match(/\{[\s\S]*\}/);
            if (jsonMatch) return JSON.parse(jsonMatch[0]);
        } catch (e) {
            console.log('⚠️ Could not parse Gemini response as JSON, using fallback');
        }
        return {
            summary: text.split('\n').slice(0, 3).join(' '),
            insights: text.split('\n').slice(3, 6).join(' '),
            emotionalState: 'Analyzed',
            confidenceLevel: 'Medium'
        };
    } catch (error) {
        console.log('⚠️ Gemini API error:', error.message);
        return generateFallbackAnalysis(emotionData, faceExpression, frameCount);
    }
}

function generateFallbackAnalysis(emotionData, faceExpression, frameCount) {
    const dominantEmotion = Object.entries(emotionData).sort((a, b) => b[1] - a[1])[0];
    let summary = `Analysis of ${frameCount} faces shows `;
    if (dominantEmotion[1] > 50) {
        summary += `dominant ${dominantEmotion[0]} emotions at ${dominantEmotion[1].toFixed(1)}%`;
    } else {
        summary += `a balanced emotional profile with ${dominantEmotion[0]} being most prominent at ${dominantEmotion[1].toFixed(1)}%`;
    }
    return {
        summary: summary,
        insights: 'The emotional distribution shows varied responses across the video frames.',
        emotionalState: dominantEmotion[0].toLowerCase(),
        confidenceLevel: 'Medium (Fallback Analysis)'
    };
}

// ================= EMOTION CALCULATION FUNCTIONS =================
function calculateConfidence(emotions) {
    const happy = emotions.HAPPY || 0;
    const calm = emotions.CALM || 0;
    const fear = emotions.FEAR || 0;
    const sad = emotions.SAD || 0;
    const angry = emotions.ANGRY || 0;
    let confidence = (happy + calm - fear - sad - angry + 100) / 2;
    return Math.round(Math.max(0, Math.min(100, confidence)) * 100) / 100;
}

function calculateAttention(emotions) {
    const surprised = emotions.SURPRISED || 0;
    const happy = emotions.HAPPY || 0;
    const calm = emotions.CALM || 0;
    let attention = (surprised * 0.5 + happy * 0.3 + calm * 0.2);
    return Math.round(Math.max(0, Math.min(100, attention)) * 100) / 100;
}

function calculateDoubt(emotions) {
    const fear = emotions.FEAR || 0;
    const sad = emotions.SAD || 0;
    const angry = emotions.ANGRY || 0;
    const disgust = emotions.DISGUSTED || 0;
    let doubt = (fear * 0.35 + sad * 0.25 + angry * 0.25 + disgust * 0.15);
    return Math.round(Math.max(0, Math.min(100, doubt)) * 100) / 100;
}

function calculateAnxiety(emotions) {
    const fear = emotions.FEAR || 0;
    const calm = emotions.CALM || 0;
    const sad = emotions.SAD || 0;
    let anxiety = (fear * 0.5 + sad * 0.3 + (100 - calm) * 0.2);
    return Math.round(Math.max(0, Math.min(100, anxiety)) * 100) / 100;
}

function calculateConfusion(emotions) {
    const surprised = emotions.SURPRISED || 0;
    const fear = emotions.FEAR || 0;
    const sad = emotions.SAD || 0;
    const happy = emotions.HAPPY || 0;
    const positive = happy;
    const negative = (fear + sad) / 2;
    const variation = Math.abs(positive - negative);
    let confusion = (surprised * 0.4 + variation * 0.3 + (100 - happy) * 0.3);
    return Math.round(Math.max(0, Math.min(100, confusion)) * 100) / 100;
}

function calculateFaceExpression(emotions) {
    const confidence = calculateConfidence(emotions);
    const attention = calculateAttention(emotions);
    const doubt = calculateDoubt(emotions);
    const anxiety = calculateAnxiety(emotions);
    const total = confidence + attention + doubt + anxiety;
    if (total > 0) {
        return {
            Confidence: Math.round((confidence / total) * 10000) / 100,
            Attention: Math.round((attention / total) * 10000) / 100,
            Doubt: Math.round((doubt / total) * 10000) / 100,
            Anxiety: Math.round((anxiety / total) * 10000) / 100
        };
    }
    return { Confidence: 25, Attention: 25, Doubt: 25, Anxiety: 25 };
}

function calculateVoiceExpression(faceExpression) {
    const confidence = faceExpression.Confidence * 0.9;
    const attention = faceExpression.Attention * 0.85;
    const doubt = faceExpression.Doubt * 0.95;
    const anxiety = faceExpression.Anxiety * 0.9;
    const total = confidence + attention + doubt + anxiety;
    if (total > 0) {
        return {
            Confidence: Math.round((confidence / total) * 10000) / 100,
            Attention: Math.round((attention / total) * 10000) / 100,
            Doubt: Math.round((doubt / total) * 10000) / 100,
            Anxiety: Math.round((anxiety / total) * 10000) / 100
        };
    }
    return { Confidence: 25, Attention: 25, Doubt: 25, Anxiety: 25 };
}

function calculateEmotionExpression(emotions) {
    const happy = emotions.HAPPY || 0;
    const neutral = emotions.CALM || 0;
    const fear = emotions.FEAR || 0;
    const confusion = calculateConfusion(emotions);
    const total = happy + neutral + fear + confusion;
    if (total > 0) {
        return {
            Happy: Math.round((happy / total) * 10000) / 100,
            Neutral: Math.round((neutral / total) * 10000) / 100,
            Fear: Math.round((fear / total) * 10000) / 100,
            Confusion: Math.round((confusion / total) * 10000) / 100
        };
    }
    return { Happy: 25, Neutral: 25, Fear: 25, Confusion: 25 };
}

function calculateScoreFromDistribution(distribution) {
    if (distribution.Happy !== undefined) {
        return Math.round(((distribution.Happy / 100) * 6 + (distribution.Neutral / 100) * 4) * 100) / 100;
    } else {
        let score = (distribution.Confidence / 100) * 5 + (distribution.Attention / 100) * 3
                   - (distribution.Doubt / 100) * 1 - (distribution.Anxiety / 100) * 1;
        return Math.round(Math.max(0, Math.min(10, score + 2)) * 100) / 100;
    }
}

function calculateOverallScores(faceExpression, voiceExpression, emotionExpression) {
    const faceScore = calculateScoreFromDistribution(faceExpression);
    const voiceScore = calculateScoreFromDistribution(voiceExpression);
    const emotionScore = calculateScoreFromDistribution(emotionExpression);
    const average = Math.round(((faceScore + voiceScore + emotionScore) / 3) * 100) / 100;
    return {
        face: faceScore,
        voice: voiceScore,
        emotion: emotionScore,
        average: average
    };
}

// ================= MAIN PROCESSING FUNCTION (local video) =================
async function processVideo(videoPath, ffmpegPath) {
    console.log('🚀 Starting video emotion analysis (local file)...');
    console.log(`💻 Platform: ${process.platform}`);
    console.log(`📂 FFmpeg path: ${ffmpegPath}`);
    console.log(`📁 Video path: ${videoPath}`);

    try {
        if (!fs.existsSync(videoPath)) {
            throw new Error(`Video file not found: ${videoPath}`);
        }

        const ffmpegAvailable = await checkFFmpeg(ffmpegPath);
        if (!ffmpegAvailable) {
            ffmpegPath = findFFmpegPath();
            console.log(`📂 New FFmpeg path: ${ffmpegPath}`);
            const retryAvailable = await checkFFmpeg(ffmpegPath);
            if (!retryAvailable) {
                throw new Error(`FFmpeg not available. Please install FFmpeg and add it to PATH.`);
            }
        }

        // Create only necessary directories (removed 'audio')
        const directories = ['uploads', 'frames', 'results'];
        for (const dir of directories) {
            if (!fs.existsSync(dir)) {
                fs.mkdirSync(dir, { recursive: true });
                console.log(`📁 Created directory: ${dir}`);
            }
        }

        console.log('🔧 Extracting frames using FFmpeg...');
        const frameDir = path.join('frames', Date.now().toString());
        fs.mkdirSync(frameDir, { recursive: true });
        const framePattern = path.join(frameDir, 'frame_%04d.jpg');

        await executeFFmpeg(ffmpegPath, videoPath, framePattern, 30);

        let frameFiles = fs.readdirSync(frameDir)
            .filter(file => file.endsWith('.jpg'))
            .map(file => path.join(frameDir, file))
            .sort();

        if (frameFiles.length === 0) {
            throw new Error('No frames extracted. FFmpeg may not be working correctly.');
        }

        console.log(`📸 Found ${frameFiles.length} frames to process`);
        if (frameFiles.length > 20) {
            console.log(`📸 Limiting to 20 frames (from ${frameFiles.length})`);
            frameFiles = frameFiles.slice(0, 20);
        }

        console.log('🔍 Analyzing frames with AWS Rekognition (v3)...');

        let frameCount = 0;
        const allEmotions = {
            HAPPY: [], SAD: [], ANGRY: [],
            FEAR: [], SURPRISED: [], DISGUSTED: [],
            CALM: []
        };
        let processedCount = 0, errorCount = 0;

        for (const img of frameFiles) {
            try {
                const imgData = fs.readFileSync(img);
                const result = await detectFaces(imgData);
                if (result.FaceDetails) {
                    for (const face of result.FaceDetails) {
                        if (face.Emotions) {
                            for (const emotion of face.Emotions) {
                                if (allEmotions[emotion.Type] !== undefined) {
                                    allEmotions[emotion.Type].push(emotion.Confidence);
                                }
                            }
                        }
                        frameCount++;
                    }
                }
                processedCount++;
                if (processedCount % 5 === 0 || processedCount === frameFiles.length) {
                    console.log(`   Processed ${processedCount}/${frameFiles.length} frames (${frameCount} faces detected)`);
                }
            } catch (error) {
                errorCount++;
                console.log(`⚠️ Error processing frame ${path.basename(img)}: ${error.message}`);
            }
        }

        console.log(`✅ Processed ${processedCount} frames, detected ${frameCount} faces (${errorCount} errors)`);

        const emotionAverages = {};
        for (const [type, scores] of Object.entries(allEmotions)) {
            emotionAverages[type] = scores.length > 0 ? (scores.reduce((a,b) => a+b, 0) / scores.length) : 0;
        }

        console.log('📊 Calculating scores...');
        const faceExpression = calculateFaceExpression(emotionAverages);
        const voiceExpression = calculateVoiceExpression(faceExpression);
        const emotionExpression = calculateEmotionExpression(emotionAverages);
        const overallScores = calculateOverallScores(faceExpression, voiceExpression, emotionExpression);

        // Gemini analysis (optional)
        console.log('🤖 Performing AI analysis with Gemini...');
        let geminiAnalysis = null;
        try {
            geminiAnalysis = await analyzeWithGemini(emotionAverages, faceExpression, frameCount);
            console.log('✅ Gemini analysis complete');
        } catch (error) {
            console.log('⚠️ Gemini analysis failed:', error.message);
        }

        const finalData = {
            timestamp: new Date().toISOString().replace('T', ' ').slice(0, 19),
            platform: process.platform,
            video_path: videoPath,
            video_file: path.basename(videoPath),
            frames_processed: frameFiles.length,
            faces_detected: frameCount,
            errors: errorCount,
            emotion_averages: emotionAverages,
            gemini_analysis: geminiAnalysis,
            scores: {
                FACE_Expression: {
                    details: faceExpression,
                    score_out_of_10: overallScores.face
                },
                VOICE_Expression: {
                    details: voiceExpression,
                    score_out_of_10: overallScores.voice
                },
                EMOTION_Expression: {
                    details: emotionExpression,
                    score_out_of_10: overallScores.emotion
                },
                OVERALL: {
                    average: overallScores.average
                }
            }
        };

        console.log('🧹 Cleaning up temporary files...');
        try {
            if (fs.existsSync(frameDir)) {
                const files = fs.readdirSync(frameDir);
                for (const file of files) {
                    try { fs.unlinkSync(path.join(frameDir, file)); } catch (_) {}
                }
                fs.rmdirSync(frameDir);
                console.log('✅ Frame directory cleaned');
            }
        } catch (error) {
            console.log('⚠️ Error cleaning up frames:', error.message);
        }

        return finalData;

    } catch (error) {
        console.error('❌ Processing failed:', error);
        throw new Error(`Processing failed: ${error.message}`);
    }
}

module.exports = {
    processVideo,
    detectFaces,
    analyzeWithGemini,
    findFFmpegPath,
    checkFFmpeg,
    executeFFmpeg,
    calculateFaceExpression,
    calculateVoiceExpression,
    calculateEmotionExpression,
    calculateOverallScores
};