import { Test, TestingModule } from '@nestjs/testing';
import { AppController } from './app.controller';

describe('AppController', () => {
  let appController: AppController;

  beforeEach(async () => {
    const app: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
    }).compile();

    appController = app.get<AppController>(AppController);
  });

  describe('root', () => {
    it('should return api metadata', () => {
      expect(appController.getInfo()).toEqual({
        name: 'syrabet-backend-api',
        version: '1.0.0',
        docs: '/docs',
        health: '/api/health',
      });
    });
  });
});
