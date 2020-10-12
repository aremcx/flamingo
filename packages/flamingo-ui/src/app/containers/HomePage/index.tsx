import * as handpose from '@tensorflow-models/handpose';
import '@tensorflow/tfjs';
import { translations } from 'locales/i18n';
import React, { useRef } from 'react';
import { Helmet } from 'react-helmet-async';
import { useTranslation } from 'react-i18next';
import ReactWebcam from 'react-webcam';
import styled, { css } from 'styled-components/macro';
import { drawHand } from 'utils/canvas/draw-hand';
import { HandposeConfig } from './types';

const shared = css`
  height: 480px;
  position: absolute;
  width: 640px;
`;

const Camera = styled(ReactWebcam)`
  ${shared}
`;

const Canvas = styled.canvas`
  ${shared}
`;

export function HomePage() {
  const { t } = useTranslation();

  const cameraRef = useRef<ReactWebcam>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);

  const runHandpose = async () => {
    const net = await handpose.load({
      detectionConfidence: 0.3,
      iouThreshold: 0.3,
      scoreThreshold: 0.5,
    } as HandposeConfig);
    console.log('Handpose finished loading');

    /* Loop and detect hands */
    setInterval(() => {
      detect(net);
    });
  };

  const detect = async (net: any) => {
    /* Check data is available */
    if (cameraRef.current != null && cameraRef.current!.video!.readyState === 4) {
      /* Get video properties */
      const { video } = cameraRef.current;
      const { videoWidth, videoHeight } = video!;

      /* Set video height and width */
      video!.width = videoWidth;
      video!.height = videoHeight;

      /* Set canvas height and width */
      canvasRef.current!.width = videoWidth;
      canvasRef.current!.height = videoHeight;
      /* Make detections */
      const hand = await net.estimateHands(video);

      /* Draw mesh */
      const context = canvasRef.current!.getContext('2d')!;
      drawHand(hand, context);
    }
  };

  runHandpose();

  return (
    <>
      <Helmet>
        <title>Home Page</title>
        <meta name="description" content={t(translations.app.quote)} />
      </Helmet>
      <Camera
        ref={cameraRef as any}
        audio={false}
        videoConstraints={{
          facingMode: 'environment',
          width: 640,
          height: 480,
        }}
      />
      <Canvas ref={canvasRef} />
    </>
  );
}
