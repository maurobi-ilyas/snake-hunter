/**
 * PLAYSTORE_READY.do.js - Deployment Status & Meta Data
 * Project: SNAKE HUNTER
 */

const PlayStoreReady = {
  packageId: "com.maurobiilyas.snake_hunter",
  appName: "Snake Hunter",
  category: "Casual / Arcade",
  contentRating: "Everyone",
  deploymentStatus: "Release Candidate V1",
  assetsStatus: {
    icon: "Adaptive Icon Implemented",
    splash: "Flutter Standard Splash",
    featureGraphic: "Pending",
    screenshots: "Verified on Physical Device"
  },
  buildConfig: {
    minSdkVersion: 21,
    targetSdkVersion: 34,
    arch: ["arm64-v8a", "armeabi-v7a", "x86_64"],
    minifyEnabled: true,
    shrinkResources: true
  }
};

module.exports = PlayStoreReady;
