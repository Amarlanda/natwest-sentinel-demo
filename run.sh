#!/bin/bash
# This script automates various development and deployment tasks, including:
# - Managing directory navigation for focused operations.
# - Loading environment variables from a .env file.
# - Validating the presence of required environment variables.
# - Orchestrating Terraform workflows (initialize, plan, apply).
# - Executing Sentinel policy checks (currently using 'sentinel test').
# The main function coordinates these operations, with specific tasks (like run_full or run_sentinel) selectable.

function move_dir() {
    # Manages directory changes, allowing to move to a new directory or return to the previous one.
    # Function body: handles directory navigation logic
    # Store current directory
    old_dir=$(pwd)
    
    # If a new directory is provided, move to it
    if [ -n "$1" ]; then
        new_dir=$1
        echo "Moving to directory: $new_dir"
        cd "$new_dir" || {
            echo "Error: Could not change to directory $new_dir"
            return 1
        }
    else
        # If no directory is provided, return to old directory
        echo "Returning to previous directory: $old_dir"
        cd "$old_dir" || {
            echo "Error: Could not return to previous directory"
            return 1
        }
    fi
}

function export_env() {
    # Loads environment variables from a .env file located in the current directory.
    echo "Exporting environment variables from .env file..."
    export $(cat .env | xargs)
    echo "Environment variables loaded successfully:"
    echo "- AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"
    echo "- AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY:0:3}... (masked)"
    echo "- AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION"
}

function check_envs_set() {
    # Verifies that essential AWS environment variables (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_DEFAULT_REGION) are set, exiting if any are missing.
    echo "Checking required environment variables..."
    # if env not set exit and tell user why
    if [ -z "$AWS_ACCESS_KEY_ID" ]; then
        echo "Error: AWS_ACCESS_KEY_ID is not set"
        echo "Please set AWS_ACCESS_KEY_ID in your .env file"
        exit 1
    fi
    if [ -z "$AWS_SECRET_ACCESS_KEY" ]; then
        echo "Error: AWS_SECRET_ACCESS_KEY is not set"
        echo "Please set AWS_SECRET_ACCESS_KEY in your .env file"
        exit 1
    fi
    if [ -z "$AWS_DEFAULT_REGION" ]; then
        echo "Error: AWS_DEFAULT_REGION is not set"
        echo "Please set AWS_DEFAULT_REGION in your .env file"
        exit 1
    fi
    echo "All required environment variables are set"
}

function terraform_init() {
    # Initializes the Terraform working directory by running `terraform init`.
    echo "Initializing Terraform configuration..."
    terraform init
}

function terraform_plan() {
    # Generates a Terraform execution plan. If an argument is provided, it saves the plan as `plan.json`.
    echo "Generating Terraform execution plan..."
    #if variable is passed in then keep plan and output it as JSON.
    if [ -n "$1" ]; then
        echo "Creating detailed JSON plan output..."
        terraform plan -json > plan.json
        echo "Plan saved to plan.json"
    else
        terraform plan
    fi
}

function terraform_apply() {
    # Applies the Terraform configuration using `terraform apply`.
    echo "Applying Terraform configuration..."
    terraform apply
} 

function run_full(){
    # Orchestrates a full Terraform deployment: navigates to the terraform directory, loads environment variables, checks them, initializes Terraform, and generates a plan (saving it as `plan.json`).
    echo "Starting Terraform deployment process..."
    move_dir "terraform"
    export_env
    check_envs_set
    terraform_init
    terraform_plan "keep_plan" # remove this var if you want to see the plan in the terminal
    echo "Deployment process completed"
    move_dir
}

function run_sentinel() {
    # Executes Sentinel policy checks by navigating to the sentinel directory and running `sentinel test`.
    echo "Running Sentinel policies..."
    move_dir "sentinel"

    echo "running command: sentinel apply"
    sentinel test
    move_dir
}

function main() {
    # Main function to orchestrate the script's execution. Resets/clears the terminal and calls selected workflow functions (currently `run_sentinel`).
  reset; clear 
  echo "starting run.sh"
  # run_full
  run_sentinel
}


main
