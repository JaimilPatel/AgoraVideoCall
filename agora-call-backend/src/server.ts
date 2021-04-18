import * as bodyParser from "body-parser"; // pull information from HTML POST (express4)
import express from "express";
import * as SocketIO from "socket.io";
import { MemCache } from "./memCache";
import { SocketEvents } from "./events";


export class App {
  protected app: express.Application;

  constructor() {
    this.app = express();

    this.app.use(bodyParser.urlencoded({ extended: true })); // parse application/x-www-form-urlencoded
    this.app.use(bodyParser.json(), (error, req, res, next) => {
      if (error) {
        return res.status(400).json({ error: req.t("ERR_GENRIC_SYNTAX") });
      }
      next();
    });
    const Server = this.app.listen(3000, () => {
      console.log("connected on 3000")
    });

    const io = SocketIO.listen(Server, {
      transports: ["websocket", "polling"],
    });

    const nsp = io.of("/chat");
    nsp.use(async (socket, next) => {
      const token = socket.handshake.query.id;
      if (token) {
        socket.user = {};
        socket.user.id = token;
        next();
      }
    }).on('connection', (socket) => {
      MemCache.hset(process.env.CHAT_SOCKET, socket.user.id, socket.id);
      const socketEvents = new SocketEvents();
      socketEvents.init(nsp, socket);
    })
  }
}
