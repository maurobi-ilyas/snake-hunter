/**
 * ANIMATION_RULES.do.js - Guidelines for smooth animations
 * Project: SNAKE HUNTER
 */

const AnimationRules = {
  tweenType: "Curves.easeInOutCubic",
  defaultDuration: "300ms",
  snake: {
    headRotationSpeed: 10, // radians per second
    bodyFlexibility: 0.8,
    eatingScale: 1.2,
  },
  prey: {
    panicWobble: true,
    transitionDuration: "200ms",
  },
  ui: {
    menuEntrance: "slideAndFade",
    buttonPress: "scaleDown",
    glassmorphismBlur: 10.0,
  }
};

module.exports = AnimationRules;
