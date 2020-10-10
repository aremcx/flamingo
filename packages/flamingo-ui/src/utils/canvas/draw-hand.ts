const fingerJoints = {
  thumb: [0, 1, 2, 3, 4],
  index: [0, 5, 6, 7, 8],
  middle: [0, 9, 10, 11, 12],
  ring: [0, 13, 14, 15, 16],
  pinky: [0, 17, 18, 19, 20],
};

// Infinity Gauntlet Style
const style = [
  { color: 'yellow', size: 15 },
  { color: 'gold', size: 6 },
  { color: 'green', size: 10 },
  { color: 'gold', size: 6 },
  { color: 'gold', size: 6 },
  { color: 'purple', size: 10 },
  { color: 'gold', size: 6 },
  { color: 'gold', size: 6 },
  { color: 'gold', size: 6 },
  { color: 'blue', size: 10 },
  { color: 'gold', size: 6 },
  { color: 'gold', size: 6 },
  { color: 'gold', size: 6 },
  { color: 'red', size: 10 },
  { color: 'gold', size: 6 },
  { color: 'gold', size: 6 },
  { color: 'gold', size: 6 },
  { color: 'orange', size: 10 },
  { color: 'gold', size: 6 },
  { color: 'gold', size: 6 },
  { color: 'gold', size: 6 },
];

export const drawHand = (
  predictions: Array<{ landmarks: Array<Array<number>> }>,
  context: CanvasRenderingContext2D,
) => {
  predictions.forEach(({ landmarks }) => {
    (Object.keys(fingerJoints) as Array<keyof typeof fingerJoints>).forEach(finger => {
      fingerJoints[finger].forEach((joint, jointIndex) => {
        if (jointIndex === fingerJoints[finger].length - 1) return;

        /* Get pairs of joints */
        const firstJointIndex = joint;
        const secondJointIndex = fingerJoints[finger][jointIndex + 1];

        /* Draw path */
        context.beginPath();
        context.moveTo(landmarks[firstJointIndex][0], landmarks[firstJointIndex][1]);
        context.lineTo(landmarks[secondJointIndex][0], landmarks[secondJointIndex][1]);
        context.strokeStyle = 'plum';
        context.lineWidth = 4;
        context.stroke();
      });
    });

    landmarks.forEach((landmark, landmarkIndex) => {
      const { 0: x, 1: y } = landmark;

      /* Start drawing */
      context.beginPath();
      context.arc(x, y, style[landmarkIndex].size, 0, 3 * Math.PI);

      /* Set line color */
      context.fillStyle = style[landmarkIndex].color;
      context.fill();
    });
  });
};
