export interface MinigameState {
    activeMinigame: string | null;
    gameId: number | null;
}
  
export interface RootState {
    minigames: MinigameState;
}
  