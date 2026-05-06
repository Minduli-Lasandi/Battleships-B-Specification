MACHINE Battleships
SEES Battleships_Ctx
INCLUDES Fleet

VARIABLES
    shots_taken, // Keeps tracck of where each player has shot
    status, // Tracks the state of the game (setup, playing or won)
    turn // Tracks the turn of the player (P1 or P2)
INVARIANT
    shots_taken : PLAYER --> POW(COORDINATES) &
    status : GAME_STATUS &
    turn : PLAYER
INITIALISATION
    shots_taken := {P1 |-> {}, P2 |-> {}} ||
    status := setting_up ||
    turn := P1

OPERATIONS
    
    
  report <-- DeploySubMarine(player, row, col) = 
  PRE player : PLAYER & row : GRID_SIZE & col : GRID_SIZE & status = setting_up THEN
      // Calls the logic in the machine Fleet
      report <-- DeploySub(player, row, col)
  END;

  report <-- DeployDestroyer(player, row, col, orient) = 
  PRE player : PLAYER & row : GRID_SIZE & col : GRID_SIZE & orient : ORIENTATION & status = setting_up THEN
      //Calls the logic in Machine Fleet
      report <-- DeployDest(player, row, col, orient)
  END;

  report <-- DeployCruiser(player, row, col, orient) = 
  PRE player : PLAYER & row : GRID_SIZE & col : GRID_SIZE & orient : ORIENTATION & status = setting_up THEN
      //Call machine Fleet to place the ship
      report <-- DeployCruis(player, row, col, orient) ||
      // Checks if the deployment completed the setup phase for both players
      IF (player = P1 & cruis_pos(P2) /= {}) or (player = P2 & cruis_pos(P1) /= {}) THEN
          status := playing // Assign playing to the status
      END
  END;



  report <-- Shoot(player, target) =
  PRE player : PLAYER & target : COORDINATES THEN
      //Checks rule - only allowed during the playing phase and if it's the players turn
    IF status = playing & player = turn THEN
      // Checking rule for not being able to shoot the same square twice
      IF target /: shots_taken(player) THEN
          // If player is P1
          IF player = P1 THEN
             shots_taken(P1) := shots_taken(P1) \/ {target} || turn := P2 ||
             //Hit detection - Check if the target in P2's fleet
             IF target : (sub_pos(P2) \/ dest_pos(P2) \/ cruis_pos(P2)) THEN
                 // Check if all p2 squares in P1's shots set
                IF (sub_pos(P2) \/ dest_pos(P2) \/ cruis_pos(P2)) <: shots_taken(P1) \/ {target} THEN
                   status := p1_win || report := P1_WIN
                ELSE
                    // Check if specific ship set is now fully in shots set
                   IF (target : sub_pos(P2)) or 
                      (target : dest_pos(P2) & dest_pos(P2) <: shots_taken(P1) \/ {target}) or 
                      (target : cruis_pos(P2) & cruis_pos(P2) <: shots_taken(P1) \/ {target}) 
                   THEN report := SUNK ELSE report := HIT END
                END
             ELSE report := MISS END
          ELSE
              // Handle P2's turn
             shots_taken(P2) := shots_taken(P2) \/ {target} || turn := P1 ||
             IF target : (sub_pos(P1) \/ dest_pos(P1) \/ cruis_pos(P1)) THEN
                IF (sub_pos(P1) \/ dest_pos(P1) \/ cruis_pos(P1)) <: shots_taken(P2) \/ {target} THEN
                   status := p2_win || report := P2_WIN
                ELSE
                   IF (target : sub_pos(P1)) or 
                      (target : dest_pos(P1) & dest_pos(P1) <: shots_taken(P2) \/ {target}) or 
                      (target : cruis_pos(P1) & cruis_pos(P1) <: shots_taken(P2) \/ {target}) 
                   THEN report := SUNK ELSE report := HIT END
                END
             ELSE report := MISS END
          END
      ELSE report := ERROR_SEQUENCE END
    ELSE report := GAME_OVER END
  END;



// Outputs the number of ships left in the player's fleet
  shipsCount <-- ShipsLeft(player) =
  PRE player : PLAYER THEN
      //Check each ship to see if they have NOT been fully hit yet
      IF player = P1 THEN
          IF sub_pos(P1) <: shots_taken(P2) THEN
              IF dest_pos(P1) <: shots_taken(P2) THEN
                  IF cruis_pos(P1) <: shots_taken(P2) THEN shipsCount := 0 ELSE shipsCount := 1 END
              ELSE
                  IF cruis_pos(P1) <: shots_taken(P2) THEN shipsCount := 1 ELSE shipsCount := 2 END
              END
          ELSE
              // Check Destroyer and Cruiser
              IF dest_pos(P1) <: shots_taken(P2) THEN
                  IF cruis_pos(P1) <: shots_taken(P2) THEN shipsCount := 1 ELSE shipsCount := 2 END
              ELSE
                  IF cruis_pos(P1) <: shots_taken(P2) THEN shipsCount := 2 ELSE shipsCount := 3 END
              END
          END
      ELSE
          //Check against P1's shots
          IF sub_pos(P2) <: shots_taken(P1) THEN
              IF dest_pos(P2) <: shots_taken(P1) THEN
                  IF cruis_pos(P2) <: shots_taken(P1) THEN shipsCount := 0 ELSE shipsCount := 1 END
              ELSE
                  IF cruis_pos(P2) <: shots_taken(P1) THEN shipsCount := 1 ELSE shipsCount := 2 END
              END
          ELSE
              IF dest_pos(P2) <: shots_taken(P1) THEN
                  IF cruis_pos(P2) <: shots_taken(P1) THEN shipsCount := 1 ELSE shipsCount := 2 END
              ELSE
                  IF cruis_pos(P2) <: shots_taken(P1) THEN shipsCount := 2 ELSE shipsCount := 3 END
              END
          END
      END
  END;



//Outputs the location of ships in the player's fleet
  shipSquares <-- LocationOfShips(player) = 
  PRE player : PLAYER THEN shipSquares := sub_pos(player) \/ dest_pos(player) \/ cruis_pos(player) END;

  shotCount <-- ShotsTaken(player) =
  PRE player : PLAYER THEN shotCount := card(shots_taken(player)) END;

  rep <-- GameState = BEGIN rep := status END
END