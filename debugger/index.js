import fs from "fs";
import WebSocket, { WebSocketServer } from "ws";

// ================= CONFIG =================
const CONSOLE_PATH =
  process.env.PZ_CONSOLE ?? `${process.env.HOME}/Zomboid/console.txt`;

const TAG = "lgd_antibodies_dev:";
const WS_PORT = 8765;
// =========================================

// --- WebSocket server ---
const wss = new WebSocketServer({ port: WS_PORT });
wss.on("connection", () => {
  console.log("WS client connected");
});

console.log(`WS listening on ws://localhost:${WS_PORT}`);
console.log(`Reading ${CONSOLE_PATH}`);

// --- Tail logic ---
let offset = fs.existsSync(CONSOLE_PATH) ? fs.statSync(CONSOLE_PATH).size : 0;

fs.watchFile(CONSOLE_PATH, { interval: 100 }, () => {
  const size = fs.statSync(CONSOLE_PATH).size;
  if (size <= offset) return;

  const stream = fs.createReadStream(CONSOLE_PATH, { start: offset });
  let buffer = "";

  stream.on("data", (chunk) => {
    buffer += chunk.toString();

    let lines = buffer.split("\n");
    buffer = lines.pop(); // keep incomplete line

    for (const line of lines) {
      if (!line.includes(TAG)) continue;

      const idx = line.indexOf(TAG);
      const jsonStr = line.slice(idx + TAG.length).trim();

      try {
        const data = JSON.parse(jsonStr);

        // 1️⃣ display locally
        console.log("IPC:", data.status.condition);

        // 2️⃣ broadcast via WebSocket
        for (const client of wss.clients) {
          if (client.readyState === WebSocket.OPEN) {
            client.send(JSON.stringify(data));
          }
        }
      } catch (err) {
        console.error("JSON parse failed:", err.message);
      }
    }
  });

  offset = size;
});
