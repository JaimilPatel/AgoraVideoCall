const { RtcTokenBuilder, RtcRole } = require("agora-access-token");
import * as dotenv from "dotenv";

dotenv.config();
// Rtc Examples
const appID = process.env.APP_ID;
const appCertificate = process.env.APP_CERTIFICATE;
const role = RtcRole.PUBLISHER;

export class Agora {

    public resourceId;

    public async generateToken(channelName) {
        // Build token with uid
        const tokenA = RtcTokenBuilder.buildTokenWithUid(appID, appCertificate, channelName, 0, role);
        return tokenA;
    }
}
