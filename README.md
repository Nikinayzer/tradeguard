# TradeGuard

A comprehensive trading automation platform consisting of multiple services and applications.

## DEMO

[![Watch the demo](https://i.ytimg.com/vi/KhdgGEheUBM/hqdefault.jpg)](https://youtu.be/KhdgGEheUBM)
> [Or download the demo video directly from GitHub](https://github.com/Nikinayzer/tradeguard-info/blob/main/tradeguard_demo.mp4) to watch a walkthrough of TradeGuard in action.

## Project Structure
- `tradeguard-server/` - Backend For Frontend (Spring Boot)
- `tradeguard-health/` - Risk Engine (Python)
- `tradeguard-mobile/` - Mobile App (React Native)
- `tradeguard-tr-latest.tar` - Trading Engine (used to be directory, now I dont have source code)

POSTMAN COLLECTION:
[Download Postman collection](https://.postman.co/workspace/My-Workspace~039a7685-18b2-44f1-89e8-232b9078f6be/collection/24952301-9384d24d-ede8-4dcb-b475-bc8cc180d4b7?action=share&creator=24952301&active-environment=24952301-66fd42f3-716d-4316-9de3-6072bd952cc3) 

## Prerequisites
- Docker and Docker Compose v2
- JDK 21 (for BFF development)
- Python 3.10+ (for Risk Engine development)
- Node.js and npm (for mobile development)

## Quick Start 
(Please, make sure to read till the end to understand the whole process)

### !!! IMPORTANT NOTE:
Trading Engine (TR) is heavily built with the idea of Discord integration, that's why it is required to put Discord-related tokens and variables into .env file. I tried to minimize this impact by tweaking the logic, however this approach might be fragile and Discord dependency should be removed in future versions. If skipped (null values), TR initializes but restarts every few seconds.

### Backend
1. Clone the repository with submodules:

   ```bash
   git clone --recursive https://github.com/nikinayzer/tradeguard.git
   cd tradeguard
   ```
2. Create .env from .env.example. in the root folder. Ensure all env variables are valid. If you were provided your own .env.example, use it instead.

   ```bash
   cp .env.example .env
   ```

3. Start backend services (It will probably take some time, as docker needs to build bff and rs):
   ```bash
   docker compose up -d
   ```
   note that this won't launch Trading Engine because it should be launched manually after adding exchange API keys via mobile app. This inconvenience is due to the nature of TR service, as it requires ID of user to launch. However, in future it can be handled automatically.

### Mobile App
   1. Create .env.local file for the mobile application:
      ```bash
      cp .env.example .env.local
      ```
      If you prefer EAS, you can try following (access is required):
      ```bash
      eas env:pull --environment development
      ```
   2. Update EXPO_PUBLIC_API_URL to point at actual server instance (BFF). Mobile device and server should be on the same network (i.e http://localhost:8080/api). However, localhost will only work if the mobile app is launched in emulator. In case of running on a real device, ensure to put real, correct IP adress. You can find more in troubleshooting section (Can't login via mobile application or mobile application doesn't launch/load)
   3. Update EXPO_PUBLIC_DISCORD_CLIENT_ID. Use real discord server ID, however you can skip this step if you don't want to use Discord auth in the app. 
   4. Put google-services.json and tradeguard-992cc-firebase-adminsdk-fbsvc-e569f6bef1.json into ROOT folder of mobile folder. Either use your own or the ones you were provided.
   ```bash
   cp ~/google-services.json ./tradeguard-mobile/google-services.json
   ```
   ```bash
   cp ~/tradeguard-992cc-firebase-adminsdk-fbsvc-e569f6bef1.json ./tradeguard-mobile/tradeguard-992cc-firebase-adminsdk-fbsvc-e569f6bef1.json
   ```
   5. Enable USB debugging in your phone. Potentially, you would need to enable developer setting first. Please, reffer to your phone documentation.
   
   6. Connect the phone via USB and Launch the app:
   ```bash
   npm install
   expo run:android
   ```
   7. After successful launch of the mobile app, register and connect an exchange account. Then (and only then) you can finally run Trade Engine.

### Trading Engine

   1. Go to root directory of this monorepo and load docker image:

   ```bash
   cd tradeguard

   docker load -i ./tradeguard-tr-latest.tar

   docker compose up tr -d
   ```
   After this step (wait for a minute or two for proper initialization) you should be able to see your equity/positions on portfolio screen and be able to create jobs (notice that you will also be able to create jobs without running TR, but they won't be processed)
   
   ### If you are having problems getting here, either look into troubleshooting section or contact me directly (Help section)

## Troubleshooting

### Common Issues

#### Can't login via mobile application or mobile application doesn't launch/load.
   - Ensure the IP address of BFF service is resolvable for mobile application. IP address of server (EXPO_PUBLIC_API_URL) is usually localhost:8080/api if mobile application is run in emaluator, but can be tricky if is run on a real device. If so, ensure that server and mobile appication are on the same network and IP address actually points at server. For example, I'm used to following method:
   1. Turn on WIFI hotspot on mobile and connect to this hotspot from your PC
   2. Find IP address for this network via ipconfig command:
   ```bash
      ipconfig
   ```
   3. Put this IP adress to mobile .env.local file like http://IP:8080/api
   4. Rebuild mobile app.
   5. If this method didn't help, its always possible to run the application in emulator, but in this case push-notifications and biometric functionalities won't be available.

#### Kafka Connection Issues

   - Ensure the correct ports are exposed (9092, 19092, 9093)
   - Check if Kafka is running in KRaft mode

#### Mobile Build Issues
   - Clear npm cache: `npm cache clean --force`
   - Reset iOS build: `cd ios && pod deintegrate && pod install`
   - Clean Android build: `cd android && ./gradlew clean`

### Logs

Access service logs:

```bash
# BFF logs
docker-compose logs -f bff

# Trading Engine logs
docker-compose logs -f tr

# Risk Engine logs
docker-compose logs -f rs
```
## Help

If you are having problems running the suite or encountering unexpected behaviour of the whole application or individual modules - don't hesitate to contact me directly, I will try to help you personally:
korotov.nick@gmail.com OR
korn03@vse.cz (MS Teams preferably)

## License

All Rights Reserved.

Permission is granted solely to authorized collaborators ("Contributors") for the following:

1. Personal or academic usage, including running or modifying the Software _within the official Project repository_.
2. No distribution, sublicense, or sale of this Software (in whole or in part) or any derivative products.
3. No creation of private or external forks. All modifications or improvements must be contributed directly to the official Project repository.

Unauthorized use, distribution, or commercialization is strictly prohibited.
For any commercial or further usage rights, written permission is required from the Owner.
