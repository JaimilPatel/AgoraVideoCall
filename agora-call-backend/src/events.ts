import * as uuid from "node-uuid";
import { Agora } from "./agora";
import { MemCache } from "./memCache";

export class SocketEvents {
    private agora = new Agora();

    private nsp;
    private socket;

    public init(nsp, socket) {
        this.nsp = nsp;
        this.socket = socket;
        this.listenEvents();
    }

    listenEvents() {
        this.connectCall();
        this.acceptCall();
        this.rejectCall();
    }

    /**
     * @param id // other user id
     * use to connect call
     */
    private connectCall() {
        this.socket.on("connectCall", async (data) => {
            const me = this.socket.user.id;
            data.channel = uuid.v1();
            data.token = await this.agora.generateToken(data.channel);
            const recSocket = MemCache.hget(process.env.CHAT_SOCKET, `${data.id}`);
            if (recSocket) {
                data.id = me;
                this.nsp.to(recSocket).emit("onCallRequest", data);
            }
        })
    }


    /**
     * @param id // other user id
     * @param channel
     * @param token
     * use to accept call
     */

    private acceptCall() {
        this.socket.on("acceptCall", async (data) => {
            const me = this.socket.user.id;
            data.otherUserId = me;

            const recSocket = MemCache.hget(process.env.CHAT_SOCKET, `${data.id}`);
            if (recSocket) {
                this.nsp.to(recSocket).emit("onAcceptCall", data);
            }
        })
    }

    /**
     * @param id // other user id
     * use to reject call
    */
    private rejectCall() {
        this.socket.on("rejectCall", async (data) => {
            const me = this.socket.user.id;
            const recSocket = MemCache.hget(process.env.CHAT_SOCKET, `${data.id}`);
            if (recSocket) {
                const res = { msg: "call disconnected" };
                this.nsp.to(recSocket).emit("onRejectCall", res);
            }
        })
    }



}