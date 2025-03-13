<p align="center">
    <img src="https://github.com/Dzeriskk5/Galutinis/blob/8ab412987f5a5be9bba93b8b9ea14628f495071b/Other/Matrix.png" width="100%" style="border: 3px solid white; border-radius: 15px; box-shadow: 0 4px 8px rgba(0, 0, 0, 0.2); transition: transform 0.3s ease;">
</p>

# Matrix Rain Effect with Flask and Socket.IO

This project creates a dynamic Matrix rain effect using Flask. The main goal is to set up a CI/CD pipeline to continuously update the code as changes are made.

## Features
- Dynamic Matrix rain effect
- Responsive design
- CI/CD pipeline for continuous deployment

## Project Structure

- `.github/workflows/`: Directory containing GitHub Actions workflows.
  - `DeployCode.yml`: Deploys the Docker app to an EC2 instance using Ansible.
  - `Infra.yml`: Manages Terraform infrastructure, including plan, apply, and destroy actions.
  - `InstallDocker.yml`: Sets up Docker on the VM using Ansible.
  - `Upload.yml`: Uploads files to the EC2 instance.
- `Ansible/`: Directory containing Ansible playbooks.
  - `Deploy.yaml`: Builds and runs the Docker container on the EC2 instance.
  - `Docker.yaml`: Prepares the VM and installs Docker.
  - `Upload.yaml`: Uploads the application files to the EC2 instance.
- `Dockerfile`: Docker configuration file to build the project image.
- `LICENSE`: License file for the project.
- `README.md`: This file, containing information about the project.
- `main.py`: Main Python script to run the Flask application.
- `requirements.txt`: Python dependencies required for the project.
- `nginx.conf`: Nginx configuration file to proxy requests to the Flask application.
- `terraform/`: Directory containing Terraform configuration files.
  - `dev.tfvars`: Terraform variables for the development environment.
  - `main.tf`: Main Terraform configuration file.
  - `prod.tfvars`: Terraform variables for the production environment.
  - `stage.tfvars`: Terraform variables for the staging environment.
  - `variables.tfvars`: Terraform variable definitions.
  - `ip_cache/ec2_ip.txt`: Stores the EC2 instance IP address after Terraform actions.

## GitHub Workflows

- `DeployCode.yml`: Deploys the Docker app to an EC2 instance using Ansible.
- `Infra.yml`: Manages Terraform infrastructure, including plan, apply, and destroy actions.
- `InstallDocker.yml`: Sets up Docker on the VM using Ansible.
- `Upload.yml`: Uploads files to the EC2 instance.

## Ansible Playbooks

- `Deploy.yaml`: Builds the Docker image and runs the Docker container on the EC2 instance.
- `Docker.yaml`: Prepares the VM by installing Docker and its dependencies.
- `Upload.yaml`: Uploads the application files (`main.py`, `Dockerfile`, `requirements.txt`, `nginx.conf`) to the EC2 instance.

## Terraform Configuration

- `dev.tfvars`: Contains Terraform variables specific to the development environment.
- `main.tf`: Main Terraform configuration file that defines the infrastructure resources.
- `prod.tfvars`: Contains Terraform variables specific to the production environment.
- `stage.tfvars`: Contains Terraform variables specific to the staging environment.
- `variables.tfvars`: Defines the variables used in the Terraform configuration.
- `ip_cache/ec2_ip.txt`: Stores the EC2 instance IP address after Terraform actions.

## Instructions

- Set up GitHub secrets for AWS credentials:
  - `AWS_ACCESS_KEY_ID`: Your AWS access key ID
  - `AWS_SECRET_ACCESS_KEY`: Your AWS secret access key
  - `AWS_SSH_KEY`: Your SSH private key for accessing the EC2 instance

- After the Terraform workflow finishes its actions, you can SSH into the EC2 instance using the following command:
  ```sh
  ssh -i ~/.ssh/Galutinis.pem ubuntu@ec2-x-x-x-x.eu-central-1.compute.amazonaws.com
  ```
  Replace `x-x-x-x` with the IP address of the EC2 instance, which can be found in the `terraform/ip_cache/ec2_ip.txt` file.

## Usage

1. Download the Git repository:
    ```sh
    git clone https://github.com/Dzeriskk5/Galutinis.git
    cd Galutinis/WorkingDir
    ```

2. Make changes to the `main.py` Python code of the Flask application.

3. Push the changes to the repository:
    ```sh
    git add main.py
    git commit -m "Update Flask application"
    git push origin main
    ```

4. The `Upload.yml` workflow will automatically detect the change, push the newest files to the EC2 instance VM, build a new Docker image, and run the Docker container with the updated application.

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Acknowledgements

- Inspired by the Matrix movie series
- Uses Flask and Socket.IO for real-time updates
