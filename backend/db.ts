import { Database } from "bun:sqlite";

// Create/open SQLite database
const db = new Database("chat.db");

// Create messages table if it doesn't exist
db.run(`
  CREATE TABLE IF NOT EXISTS messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL,
    text TEXT NOT NULL,
    timestamp INTEGER NOT NULL
  )
`);

console.log("✅ Database initialized");

/**
 * Save a new message to the database
 * @param username - The user who sent the message
 * @param text - The message content
 */
export function saveMessage(username: string, text: string): void {
  const timestamp = Date.now(); // Current time in milliseconds

  const stmt = db.prepare(
    "INSERT INTO messages (username, text, timestamp) VALUES (?, ?, ?)"
  );

  stmt.run(username, text, timestamp);
}

/**
 * Get the most recent messages from the database
 * @param limit - Maximum number of messages to retrieve
 * @returns Array of message objects
 */
export function getRecentMessages(limit: number = 100): Array<{
  id: number;
  username: string;
  text: string;
  timestamp: number;
}> {
  const stmt = db.prepare(
    "SELECT id, username, text, timestamp FROM messages ORDER BY timestamp DESC LIMIT ?"
  );

  const messages = stmt.all(limit) as Array<{
    id: number;
    username: string;
    text: string;
    timestamp: number;
  }>;

  // Reverse to get chronological order (oldest first)
  return messages.reverse();
}

// Close database when process exits
process.on("SIGINT", () => {
  db.close();
  process.exit(0);
});
