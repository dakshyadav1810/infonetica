# Infonetica Workflow Engine

A configurable state machine workflow engine built with .NET Minimal APIs. This service allows you to create workflow blueprints (templates) and run workflow instances that transition through predefined states based on configured actions.

## Overview

The Infonetica Workflow Engine provides a REST API for managing state machine workflows. You can define workflow blueprints with states and transitions, then create and execute workflow instances that follow those templates.

### Key Concepts

- **Workflow Blueprint**: A template that defines the states and possible transitions for a workflow type
- **Workflow State**: A specific step or status in the workflow (e.g., "Draft", "Approved", "Rejected")
- **Workflow Action**: A transition that moves a workflow from one state to another (e.g., "Submit for Review")
- **Running Workflow**: An active instance of a workflow blueprint that tracks its current state and history

## Getting Started

### Prerequisites

- .NET 9 SDK
- A terminal or command prompt

### Running the Application

1. Clone or download the project
2. Navigate to the project directory
3. Run the application:

```bash
dotnet run
```

The API will start on `http://localhost:5074` by default.

## API Endpoints

### Health Check

**GET /** 
Returns a simple status message to verify the API is running.

```bash
curl http://localhost:5074/
```

### Blueprint Management

Blueprints are the templates that define how workflows should behave.

#### Create a Blueprint

**POST /blueprints**
Creates a new workflow blueprint with states and actions.

```bash
curl -X POST http://localhost:5074/blueprints \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Document Approval",
    "states": [
      {
        "id": "draft",
        "name": "Draft",
        "isInitial": true,
        "isFinal": false,
        "isEnabled": true
      },
      {
        "id": "approved",
        "name": "Approved",
        "isInitial": false,
        "isFinal": true,
        "isEnabled": true
      }
    ],
    "actions": [
      {
        "id": "approve",
        "name": "Approve Document",
        "isEnabled": true,
        "fromStates": ["draft"],
        "toState": "approved"
      }
    ]
  }'
```

#### Get All Blueprints

**GET /blueprints**
Returns a list of all created blueprints.

```bash
curl http://localhost:5074/blueprints
```

#### Get a Specific Blueprint

**GET /blueprints/{id}**
Returns details for a specific blueprint by its ID.

```bash
curl http://localhost:5074/blueprints/your-blueprint-id
```

### Workflow Management

Workflows are active instances that follow a blueprint's rules.

#### Start a Workflow

**POST /workflows**
Creates a new running workflow instance from a blueprint.

```bash
curl -X POST http://localhost:5074/workflows \
  -H "Content-Type: application/json" \
  -d '{
    "blueprintId": "your-blueprint-id"
  }'
```

#### Get All Running Workflows

**GET /workflows**
Returns a list of all active workflow instances.

```bash
curl http://localhost:5074/workflows
```

#### Get a Specific Workflow

**GET /workflows/{id}**
Returns details for a specific workflow instance, including its current state and history.

```bash
curl http://localhost:5074/workflows/your-workflow-id
```

#### Execute an Action on a Workflow

**POST /workflows/{workflowId}/execute**
Performs an action on a workflow, potentially changing its state.

```bash
curl -X POST http://localhost:5074/workflows/your-workflow-id/execute \
  -H "Content-Type: application/json" \
  -d '{
    "actionId": "approve"
  }'
```

## Data Validation and Business Rules

The engine enforces several important rules:

### Blueprint Validation
- Each blueprint must have exactly one state marked as initial
- All state IDs within a blueprint must be unique
- Actions must reference valid state IDs that exist in the blueprint
- Each action must specify valid "from" states and a valid "to" state

### Workflow Execution Rules
- New workflows automatically start in the blueprint's initial state
- Actions can only be executed if they are enabled
- Actions can only be executed from valid starting states
- Once a workflow reaches a final state, no further actions can be executed
- All state transitions are recorded in the workflow's history

## Response Codes

The API uses standard HTTP status codes:

- **200 OK**: Successful retrieval or action execution
- **201 Created**: Successful creation of blueprint or workflow
- **400 Bad Request**: Invalid input data or validation errors
- **404 Not Found**: Requested resource does not exist
- **409 Conflict**: Business rule violation (e.g., trying to execute action on final state)
- **500 Internal Server Error**: Unexpected server error

## Design Assumptions

Several design decisions were made:

### State Management
- Workflows automatically start in the initial state when created
- Final states are terminal - no actions can be executed once reached
- State transitions are atomic - either they succeed completely or fail with no partial changes

### Data Persistence
- All data is stored in memory and will be lost when the application restarts
- The in-memory stores are thread-safe for concurrent access
- Unique identifiers are generated automatically using GUIDs

## Architecture

- **Models**: Core domain entities as immutable records
- **Payloads**: Request/response data transfer objects
- **Stores**: Data persistence abstractions with in-memory implementations
- **Services**: Business logic and orchestration layer
- **Program.cs**: API configuration and endpoint definitions
