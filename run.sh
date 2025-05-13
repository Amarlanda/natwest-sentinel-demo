#!/bin/bash


function move_dir() {
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
    echo "Exporting environment variables from .env file..."
    export $(cat .env | xargs)
    echo "Environment variables loaded successfully:"
    echo "- AWS_ACCESS_KEY_ID: $AWS_ACCESS_KEY_ID"
    echo "- AWS_SECRET_ACCESS_KEY: ${AWS_SECRET_ACCESS_KEY:0:3}... (masked)"
    echo "- AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION"
}

function check_envs_set() {
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
    echo "Initializing Terraform configuration..."
    terraform init
}

function terraform_plan() {
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
    echo "Applying Terraform configuration..."
    terraform apply
} 

function run_full(){
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
    echo "Running Sentinel policies..."
    move_dir "sentinel"

    echo "running command: sentinel apply"
    sentinel test
    move_dir
}
function main() {

  reset; clear 
  echo "starting run.sh"
  # run_full
  run_sentinel
}


main
