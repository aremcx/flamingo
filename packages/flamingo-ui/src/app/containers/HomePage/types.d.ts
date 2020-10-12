export interface HandposeConfig {
  /**
   * How many frames to go without running the bounding box detector. Set to a lower value if you want a safety net in case the mesh detector produces consistently flawed predictions.
   *
   * @default infinity
   */
  maxContinuousChecks: any;

  /**
   * Threshold for discarding a prediction.
   *
   * @default 0.8
   */
  detectionConfidence: number;

  /**
   * A float representing the threshold for deciding whether boxes overlap too much in non-maximum suppression. Must be between [0, 1].
   *
   * @default 0.3
   */
  iouThreshold: number;

  /**
   * A threshold for deciding when to remove boxes based on score in non-maximum suppression.
   *
   * @default 0.75
   */
  scoreThreshold: number;
}
