-- Create carpool_participants table
CREATE TABLE IF NOT EXISTS carpool_participants (
    carpool_id INTEGER REFERENCES carpool_requests(id),
    user_id INTEGER REFERENCES users(id),
    PRIMARY KEY (carpool_id, user_id)
);

-- Add any necessary indexes
CREATE INDEX IF NOT EXISTS idx_carpool_participants_carpool_id ON carpool_participants(carpool_id);
CREATE INDEX IF NOT EXISTS idx_carpool_participants_user_id ON carpool_participants(user_id);
