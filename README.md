# DSCI_532_individual-assignment_seanmck

DSCI 532 individual-assignment for Sean McKay (seanmck)

## Motivation

Target audience: Hospital Administrators

Understanding the breakdown of mortality rates by cause and age across time allows administrators to understand where resources might best be applied in order to decrease the death rate for causes of most concern.

## App Description 

The app dashboard includes 

## Installation Instructions

To run the **Canadian Death Dashboard** project locally on your machine, follow these steps:

1. **Clone the Repository**

    Open your terminal, go to the desired directory, and clone the repository

    ```bash
    git clone https://github.ubc.ca/MDS-2023-24/DSCI_532_individual-assignment_seanmck.git
    ```

2. **Navigate to the Project Directory**

    Once you've cloned the repository, switch to the project directory by running the following command in your terminal:

    ```bash
    cd DSCI_532_individual-assignment_seanmck
    ```

3. **Create a Conda Environment**

    Create a Conda environment named `death-dashboard` using the `environment.yaml` file located in the root of the directory. This will install all required packages for the project

    ```bash
    conda env create -f environment.yml
    ```

4. **Activate the Conda Environment**

    After creating the environment, activate it with the following command:

    ```bash
    conda activate death-dashboard
    ```

5. **Run the Application**

    With the `death-dashboard` environment activated, you can now start the application:

    ```bash
    R -e "shiny::runApp('src/')"
    ```

    This command will start the application. Follow any on-screen instructions to access it in your web browser.
    By default, you will see `Listening on http://127.0.0.1:8050`.
