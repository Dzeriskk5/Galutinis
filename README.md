<p align="center">
    <img src="https://github.com/Dzeriskk5/Galutinis/blob/8ab412987f5a5be9bba93b8b9ea14628f495071b/Other/Matrix.png" width="100%" style="border: 3px solid white; border-radius: 15px; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2); transition: transform 0.3s ease;">
</p>

# Matrix Rain Effect with Flask and Socket.IO

This project creates a dynamic Matrix rain effect using Flask and Socket.IO. The Matrix effect alternates with a cat silhouette every 10 seconds.

## Features
- Dynamic Matrix rain effect
- Cat silhouette display
- Responsive design
- Real-time updates using Socket.IO

## Getting Started

### Prerequisites
- Docker
- Docker Compose

### Installation

1. Clone the repository:
    ```sh
    git clone https://github.com/Dzeriskk5/Galutinis.git
    cd Galutinis
    ```

2. Build the Docker image:
    ```sh
    docker build -t matrix-rain .
    ```

3. Run the Docker container:
    ```sh
    docker run -d -p 80:80 --name matrix-rain-container matrix-rain
    ```

4. Open your web browser and navigate to `http://localhost` to see the Matrix rain effect.

## Usage

The Matrix rain effect will run for 10 seconds, followed by a cat silhouette for 10 seconds, and then repeat.

## Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

- Inspired by the Matrix movie series
- Uses Flask and Socket.IO for real-time updates
