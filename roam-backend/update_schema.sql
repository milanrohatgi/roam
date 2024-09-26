ALTER TABLE carpool_requests
ADD COLUMN status VARCHAR(20) DEFAULT 'open';

-- Update existing rows to have 'open' status
UPDATE carpool_requests SET status = 'open' WHERE status IS NULL;
