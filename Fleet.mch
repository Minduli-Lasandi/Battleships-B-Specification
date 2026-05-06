MACHINE Fleet
SEES Battleships_Ctx
    
    
VARIABLES
    sub_pos, dest_pos, cruis_pos //Set of coordinated for the ship type
    
    
INVARIANT
    sub_pos : PLAYER --> POW(COORDINATES) &
    dest_pos : PLAYER --> POW(COORDINATES) &
    cruis_pos : PLAYER --> POW(COORDINATES)
    
    
INITIALISATION
    //All ships start with empty sets for both players
    sub_pos := {P1 |-> {}, P2 |-> {}} || 
    dest_pos := {P1 |-> {}, P2 |-> {}} ||
    cruis_pos := {P1 |-> {}, P2 |-> {}}
    
    
OPERATIONS
    
  rep <-- DeploySub(pp, row, col) =
  PRE pp : PLAYER & row : GRID_SIZE & col : GRID_SIZE THEN
      IF sub_pos(pp) = {} THEN // Checks if the submarine is already placed
          sub_pos(pp) := {(row |-> col)} || rep := SUCCESS // Assign the single coordinate to the submarine set 
      ELSE rep := ERROR_SEQUENCE END // Else report an error
  END;


  rep <-- DeployDest(pp, row, col, orient) =
  PRE pp : PLAYER & row : GRID_SIZE & col : GRID_SIZE & orient : ORIENTATION THEN
      //Check the sequence: Must place the sub before destroyer
      IF sub_pos(pp) /= {} & dest_pos(pp) = {} THEN
          IF orient = horizontal THEN
              // Check the boundary if both squared are inside the 1..10 grid
              IF {(row |-> col), (row |-> col + 1)} <: COORDINATES THEN
                  // Check if these squared are free from the submarine
                  IF {(row |-> col), (row |-> col + 1)} /\ sub_pos(pp) = {} THEN
                      dest_pos(pp) := {(row |-> col), (row |-> col + 1)} || rep := SUCCESS
                  ELSE rep := ERROR_OVERLAP END
              ELSE rep := ERROR_OUT_OF_BOUNDS END
          ELSE // vertical 
              IF {(row |-> col), (row + 1 |-> col)} <: COORDINATES THEN
                  IF {(row |-> col), (row + 1 |-> col)} /\ sub_pos(pp) = {} THEN
                      dest_pos(pp) := {(row |-> col), (row + 1 |-> col)} || rep := SUCCESS
                  ELSE rep := ERROR_OVERLAP END // Report error for overlap
              ELSE rep := ERROR_OUT_OF_BOUNDS END // Report out of bound error
          END
      ELSE rep := ERROR_SEQUENCE END
  END;



  rep <-- DeployCruis(pp, row, col, orient) =
  PRE pp : PLAYER & row : GRID_SIZE & col : GRID_SIZE & orient : ORIENTATION THEN
      // Check sequence: Must place destroyer before cruiser
      IF dest_pos(pp) /= {} & cruis_pos(pp) = {} THEN
          IF orient = horizontal THEN
              // Check boundary if all the three squared are in the grid
              IF {(row |-> col), (row |-> col + 1), (row |-> col + 2)} <: COORDINATES THEN
                  // Check if these squared are free from the submarine and the destroyer
                  IF {(row |-> col), (row |-> col + 1), (row |-> col + 2)} /\ (sub_pos(pp) \/ dest_pos(pp)) = {} THEN
                      cruis_pos(pp) := {(row |-> col), (row |-> col + 1), (row |-> col + 2)} || rep := SUCCESS
                  ELSE rep := ERROR_OVERLAP END
              ELSE rep := ERROR_OUT_OF_BOUNDS END
          ELSE //vertical
              IF {(row |-> col), (row + 1 |-> col), (row + 2 |-> col)} <: COORDINATES THEN
                  IF {(row |-> col), (row + 1 |-> col), (row + 2 |-> col)} /\ (sub_pos(pp) \/ dest_pos(pp)) = {} THEN
                      cruis_pos(pp) := {(row |-> col), (row + 1 |-> col), (row + 2 |-> col)} || rep := SUCCESS
                  ELSE rep := ERROR_OVERLAP END // Report Error for overlap
              ELSE rep := ERROR_OUT_OF_BOUNDS END
          END
      ELSE rep := ERROR_SEQUENCE END
  END
END