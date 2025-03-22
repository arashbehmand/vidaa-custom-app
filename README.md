# Vidaa Custom App Installer

This project creates a DNS and web server to enable installation of custom apps on Hisense TVs running VidaaOS. It works by spoofing the `vidaahub.com` domain and providing a customized web interface that utilizes the TV's browser APIs to install apps.

## How It Works

1. The container runs both a DNS server (dnsmasq) and a web server (Nginx)
2. DNS redirects `vidaahub.com` and `vidaahubimg.com` to your server's IP address
3. Nginx serves the web content over HTTPS with a self-signed certificate
4. The web interface loads app configurations from a YAML file
5. When a user selects an app to install, it uses the Hisense browser APIs to install it

## Setup

### Prerequisites

- Docker and Docker Compose
- A Hisense TV with VidaaOS
- Both your server and TV on the same network

### Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/yourusername/vidaa-custom-app.git
   cd vidaa-custom-app
   ```

2. Create the necessary folders:
   ```bash
   mkdir -p config/nginx images/ui certs
   ```

3. Add app icons to the appropriate directories:
   - Put app icons in `images/ui/` (named as `appId.png`)
   - Put app thumbnails in `images/` (named as `appId.png`)

4. Build and start the container:
   ```bash
   docker-compose up --build
   ```

5. On your TV, set the DNS server to your server's IP address (displayed in the container logs)

## Configuration

### Adding Custom Apps

Edit the `config.yaml` file to add, remove, or modify apps:

```yaml
apps:
  - appId: "my_custom_app"
    name: "My Custom App"
    url: "https://example.com/app"
    text: "Description of the app"
    storeType: "hisense"  # Optional, defaults to "store"
```

### Customizing Appearance

The theme colors can be modified in the `config.yaml` file:

```yaml
theme:
  default_background_color: "#fafafa"
  default_text_color: "#0f0f0f"
```

## Project Structure

```
vidaa-custom-app/
├── Dockerfile              # Docker image definition
├── docker-compose.yml      # Container orchestration
├── config/                 # Configuration files
│   ├── dnsmasq.conf        # DNS server config
│   └── nginx/
│       └── app.conf        # Nginx server config
├── data/                   # Web content
│   └── web/
│       └── index.html      # Main application HTML
├── images/                 # App thumbnails
│   └── ui/                 # App icons
├── config.yaml             # App configurations
├── supervisord.conf        # Service supervisor config
├── entrypoint.sh           # Container startup script
└── certs/                  # SSL certificates (auto-generated)
```

## Security Notes

- This uses a self-signed certificate which will show as "not secure" in browsers
- The TV browser will likely accept the certificate without warning
- Only use this on a trusted network

## Troubleshooting

- If the TV can't connect to the server, ensure that:
  - Both devices are on the same network
  - Your server's firewall allows traffic on ports 53/UDP, 80, and 443
  - The TV is using your server as its DNS server

- If apps don't appear, check:
  - App images are correctly named and placed in the proper directories
  - The `config.yaml` file is properly formatted 