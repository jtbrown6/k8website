# Playbook: Updating the Website Container

This document outlines the steps to update the local website repository with the latest changes from the official GitHub repository and rebuild the Docker container image.

## Prerequisites

*   Git installed locally.
*   Docker installed locally.
*   A local clone of the website repository (`kubernetes/website`).

## Update Process

Follow these steps whenever you need to incorporate the latest changes from the upstream repository into your Docker image:

1.  **Navigate to Your Local Repository:**
    Open your terminal and change to the directory where you cloned the website repository.
    ```bash
    cd path/to/your/local/website-clone
    ```

2.  **Ensure You Are on the Main Branch:**
    Make sure you are on the main branch (or the primary branch you track).
    ```bash
    git checkout main
    ```
    *(Replace `main` if you track a different branch)*

3.  **Fetch Upstream Changes:**
    Fetch the latest changes from the official `kubernetes/website` repository. If you haven't added it as a remote yet, you might need to do that first (e.g., `git remote add upstream https://github.com/kubernetes/website.git`).
    ```bash
    git fetch upstream
    ```
    *(Replace `upstream` with the name you gave the remote for the official repository)*

4.  **Pull Changes into Your Local Branch:**
    Merge the fetched changes into your local main branch.
    ```bash
    git pull upstream main
    ```
    *(Replace `upstream` and `main` as needed)*

5.  **Check for Hugo Version Changes (Optional but Recommended):**
    Sometimes, updates to the website or its theme (Docsy) might require a newer version of Hugo.
    *   Check the project's documentation or release notes if available.
    *   Look at files like `netlify.toml` in the updated code, as they sometimes specify the Hugo version used for official builds (search for `HUGO_VERSION`).
    *   If you are unsure, you can try building the image (Step 7) and see if Hugo errors occur.

6.  **Update Dockerfile (If Necessary):**
    If you determined that a new Hugo version is required:
    *   Open the `Dockerfile` in your editor.
    *   Locate the `ARG HUGO_VERSION=` line.
    *   Update the version number to the required version. For example:
        ```diff
        - ARG HUGO_VERSION=0.133.0
        + ARG HUGO_VERSION=0.134.0
        ```
    *   Save the `Dockerfile`.

7.  **Rebuild the Docker Image:**
    Build the image using the `docker build` command. Using the same tag (`website-image:latest` in this example) will overwrite the previous image version.
    ```bash
    docker build -t website-image:latest .
    ```
    *(Replace `website-image:latest` if you use a different name/tag)*
    Monitor the build output for any errors.

8.  **Stop and Remove the Old Container (If Running):**
    If you have a container running from the *previous* image version, you need to stop and remove it before starting a new one with the updated image.
    ```bash
    # Find the container ID or name (if you don't remember it)
    docker ps

    # Stop the running container (using the name from container.md example)
    docker stop website-container

    # Remove the stopped container
    docker rm website-container
    ```
    *(Replace `website-container` with the actual name of your running container)*

9.  **Run the New Container:**
    Start a new container using the freshly built image.
    ```bash
    docker run -d -p 8080:80 --name website-container website-image:latest
    ```
    *(Adjust port mapping `-p 8080:80` and container name `--name website-container` as needed)*

10. **Verify:**
    Open your web browser and navigate to `http://localhost:8080` (or the host port you chose) to ensure the updated website is running correctly.

You have now successfully updated your local code and rebuilt/redeployed the website container with the latest changes.
