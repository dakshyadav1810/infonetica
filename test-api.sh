#!/bin/bash

API_URL="http://localhost:5074"

echo "CURL Tester - Infonetica API"
echo "1. Health Check"
echo "2. Create Valid Blueprint"
echo "3. Create Invalid Blueprint (No Initial State)"
echo "4. Create Invalid Blueprint (Duplicate States)"
echo "5. Get All Blueprints"
echo "6. Get Blueprint by ID (Valid)"
echo "7. Get Blueprint by ID (Invalid)"
echo "8. Start Workflow"
echo "9. Start Workflow (Invalid Blueprint)"
echo "10. Get All Workflows"
echo "11. Get Workflow by ID (Valid)"
echo "12. Get Workflow by ID (Invalid)"
echo "13. Execute Action (Valid Transition)"
echo "14. Execute Action (Invalid Action)"
echo "15. Execute Action on Final State"
echo "16. Complete Workflow Journey"
echo "17. Execute All Error Cases"

read -p "Enter pathway number: " pathway

case $pathway in
  1)
    echo "Testing Health Check"
    curl -s $API_URL/
    echo
    ;;
    
  2)
    echo "Testing Create Valid Blueprint"
    curl -s -X POST $API_URL/blueprints \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Student Application Process",
        "states": [
          {
            "id": "submitted",
            "name": "Application Submitted",
            "isInitial": true,
            "isFinal": false,
            "isEnabled": true
          },
          {
            "id": "under_review",
            "name": "Under Review",
            "isInitial": false,
            "isFinal": false,
            "isEnabled": true
          },
          {
            "id": "interview_scheduled",
            "name": "Interview Scheduled",
            "isInitial": false,
            "isFinal": false,
            "isEnabled": true
          },
          {
            "id": "accepted",
            "name": "Accepted",
            "isInitial": false,
            "isFinal": true,
            "isEnabled": true
          },
          {
            "id": "rejected",
            "name": "Rejected",
            "isInitial": false,
            "isFinal": true,
            "isEnabled": true
          }
        ],
        "actions": [
          {
            "id": "review",
            "name": "Start Review",
            "isEnabled": true,
            "fromStates": ["submitted"],
            "toState": "under_review"
          },
          {
            "id": "schedule_interview",
            "name": "Schedule Interview",
            "isEnabled": true,
            "fromStates": ["under_review"],
            "toState": "interview_scheduled"
          },
          {
            "id": "accept",
            "name": "Accept Application",
            "isEnabled": true,
            "fromStates": ["interview_scheduled"],
            "toState": "accepted"
          },
          {
            "id": "reject_after_review",
            "name": "Reject After Review",
            "isEnabled": true,
            "fromStates": ["under_review"],
            "toState": "rejected"
          },
          {
            "id": "reject_after_interview",
            "name": "Reject After Interview",
            "isEnabled": true,
            "fromStates": ["interview_scheduled"],
            "toState": "rejected"
          }
        ]
      }'
    echo
    ;;
    
  3)
    echo "Testing Create Invalid Blueprint - No Initial State (Expected Error)"
    curl -s -X POST $API_URL/blueprints \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Invalid Process",
        "states": [
          {
            "id": "state1",
            "name": "State 1",
            "isInitial": false,
            "isFinal": false,
            "isEnabled": true
          },
          {
            "id": "state2",
            "name": "State 2",
            "isInitial": false,
            "isFinal": true,
            "isEnabled": true
          }
        ],
        "actions": [
          {
            "id": "action1",
            "name": "Action 1",
            "isEnabled": true,
            "fromStates": ["state1"],
            "toState": "state2"
          }
        ]
      }'
    echo
    ;;
    
  4)
    echo "Testing Create Invalid Blueprint - Duplicate States (Expected Error)"
    curl -s -X POST $API_URL/blueprints \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Duplicate States Process",
        "states": [
          {
            "id": "duplicate",
            "name": "First State",
            "isInitial": true,
            "isFinal": false,
            "isEnabled": true
          },
          {
            "id": "duplicate",
            "name": "Second State",
            "isInitial": false,
            "isFinal": true,
            "isEnabled": true
          }
        ],
        "actions": [
          {
            "id": "action1",
            "name": "Action 1",
            "isEnabled": true,
            "fromStates": ["duplicate"],
            "toState": "duplicate"
          }
        ]
      }'
    echo
    ;;
    
  5)
    echo "Testing Get All Blueprints"
    curl -s $API_URL/blueprints
    echo
    ;;
    
  6)
    echo "Testing Get Blueprint by Valid ID"
    echo "First creating a blueprint to get its ID"
    response=$(curl -s -X POST $API_URL/blueprints \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Simple Process",
        "states": [
          {
            "id": "start",
            "name": "Start",
            "isInitial": true,
            "isFinal": false,
            "isEnabled": true
          },
          {
            "id": "end",
            "name": "End",
            "isInitial": false,
            "isFinal": true,
            "isEnabled": true
          }
        ],
        "actions": [
          {
            "id": "finish",
            "name": "Finish",
            "isEnabled": true,
            "fromStates": ["start"],
            "toState": "end"
          }
        ]
      }')
    
    blueprint_id=$(echo $response | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "Created blueprint with ID: $blueprint_id"
    echo "Now fetching it:"
    curl -s $API_URL/blueprints/$blueprint_id
    echo
    ;;
    
  7)
    echo "Testing Get Blueprint by Invalid ID (Expected Error)"
    curl -s $API_URL/blueprints/non-existent-id
    echo
    ;;
    
  8)
    echo "Testing Start Workflow"
    echo "First creating a blueprint"
    response=$(curl -s -X POST $API_URL/blueprints \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Application Flow",
        "states": [
          {
            "id": "applied",
            "name": "Applied",
            "isInitial": true,
            "isFinal": false,
            "isEnabled": true
          },
          {
            "id": "completed",
            "name": "Completed",
            "isInitial": false,
            "isFinal": true,
            "isEnabled": true
          }
        ],
        "actions": [
          {
            "id": "complete",
            "name": "Complete",
            "isEnabled": true,
            "fromStates": ["applied"],
            "toState": "completed"
          }
        ]
      }')
    
    blueprint_id=$(echo $response | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "Created blueprint with ID: $blueprint_id"
    echo "Now starting workflow:"
    curl -s -X POST $API_URL/workflows \
      -H "Content-Type: application/json" \
      -d "{\"blueprintId\": \"$blueprint_id\"}"
    echo
    ;;
    
  9)
    echo "Testing Start Workflow with Invalid Blueprint (Expected Error)"
    curl -s -X POST $API_URL/workflows \
      -H "Content-Type: application/json" \
      -d '{"blueprintId": "invalid-blueprint-id"}'
    echo
    ;;
    
  10)
    echo "Testing Get All Workflows"
    curl -s $API_URL/workflows
    echo
    ;;
    
  11)
    echo "Testing Get Workflow by Valid ID"
    echo "First creating blueprint and workflow"
    blueprint_response=$(curl -s -X POST $API_URL/blueprints \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Quick Process",
        "states": [
          {
            "id": "new",
            "name": "New",
            "isInitial": true,
            "isFinal": false,
            "isEnabled": true
          },
          {
            "id": "done",
            "name": "Done",
            "isInitial": false,
            "isFinal": true,
            "isEnabled": true
          }
        ],
        "actions": [
          {
            "id": "complete",
            "name": "Complete",
            "isEnabled": true,
            "fromStates": ["new"],
            "toState": "done"
          }
        ]
      }')
    
    blueprint_id=$(echo $blueprint_response | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    
    workflow_response=$(curl -s -X POST $API_URL/workflows \
      -H "Content-Type: application/json" \
      -d "{\"blueprintId\": \"$blueprint_id\"}")
    
    workflow_id=$(echo $workflow_response | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "Created workflow with ID: $workflow_id"
    echo "Now fetching it:"
    curl -s $API_URL/workflows/$workflow_id
    echo
    ;;
    
  12)
    echo "Testing Get Workflow by Invalid ID (Expected Error)"
    curl -s $API_URL/workflows/non-existent-workflow-id
    echo
    ;;
    
  13)
    echo "Testing Execute Valid Action"
    echo "Creating blueprint and workflow first"
    blueprint_response=$(curl -s -X POST $API_URL/blueprints \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Evaluation Process",
        "states": [
          {
            "id": "pending",
            "name": "Pending",
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
            "name": "Approve",
            "isEnabled": true,
            "fromStates": ["pending"],
            "toState": "approved"
          }
        ]
      }')
    
    blueprint_id=$(echo $blueprint_response | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    
    workflow_response=$(curl -s -X POST $API_URL/workflows \
      -H "Content-Type: application/json" \
      -d "{\"blueprintId\": \"$blueprint_id\"}")
    
    workflow_id=$(echo $workflow_response | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "Created workflow with ID: $workflow_id"
    echo "Executing approve action:"
    curl -s -X POST $API_URL/workflows/$workflow_id/execute \
      -H "Content-Type: application/json" \
      -d '{"actionId": "approve"}'
    echo
    ;;
    
  14)
    echo "Testing Execute Invalid Action (Expected Error)"
    echo "Creating blueprint and workflow first"
    blueprint_response=$(curl -s -X POST $API_URL/blueprints \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Test Process",
        "states": [
          {
            "id": "initial",
            "name": "Initial",
            "isInitial": true,
            "isFinal": false,
            "isEnabled": true
          },
          {
            "id": "final",
            "name": "Final",
            "isInitial": false,
            "isFinal": true,
            "isEnabled": true
          }
        ],
        "actions": [
          {
            "id": "proceed",
            "name": "Proceed",
            "isEnabled": true,
            "fromStates": ["initial"],
            "toState": "final"
          }
        ]
      }')
    
    blueprint_id=$(echo $blueprint_response | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    
    workflow_response=$(curl -s -X POST $API_URL/workflows \
      -H "Content-Type: application/json" \
      -d "{\"blueprintId\": \"$blueprint_id\"}")
    
    workflow_id=$(echo $workflow_response | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "Created workflow with ID: $workflow_id"
    echo "Executing invalid action:"
    curl -s -X POST $API_URL/workflows/$workflow_id/execute \
      -H "Content-Type: application/json" \
      -d '{"actionId": "non_existent_action"}'
    echo
    ;;
    
  15)
    echo "Testing Execute Action on Final State (Expected Error)"
    echo "Creating blueprint and workflow, moving to final state"
    blueprint_response=$(curl -s -X POST $API_URL/blueprints \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Final State Test",
        "states": [
          {
            "id": "active",
            "name": "Active",
            "isInitial": true,
            "isFinal": false,
            "isEnabled": true
          },
          {
            "id": "closed",
            "name": "Closed",
            "isInitial": false,
            "isFinal": true,
            "isEnabled": true
          }
        ],
        "actions": [
          {
            "id": "close",
            "name": "Close",
            "isEnabled": true,
            "fromStates": ["active"],
            "toState": "closed"
          }
        ]
      }')
    
    blueprint_id=$(echo $blueprint_response | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    
    workflow_response=$(curl -s -X POST $API_URL/workflows \
      -H "Content-Type: application/json" \
      -d "{\"blueprintId\": \"$blueprint_id\"}")
    
    workflow_id=$(echo $workflow_response | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    
    echo "Moving workflow to final state"
    curl -s -X POST $API_URL/workflows/$workflow_id/execute \
      -H "Content-Type: application/json" \
      -d '{"actionId": "close"}' > /dev/null
    
    echo "Attempting to execute action on final state:"
    curl -s -X POST $API_URL/workflows/$workflow_id/execute \
      -H "Content-Type: application/json" \
      -d '{"actionId": "close"}'
    echo
    ;;
    
  16)
    echo "Testing Complete Workflow Journey"
    echo "Step 1: Create blueprint"
    blueprint_response=$(curl -s -X POST $API_URL/blueprints \
      -H "Content-Type: application/json" \
      -d '{
        "name": "Full Journey Process",
        "states": [
          {
            "id": "application_received",
            "name": "Application Received",
            "isInitial": true,
            "isFinal": false,
            "isEnabled": true
          },
          {
            "id": "screening",
            "name": "Initial Screening",
            "isInitial": false,
            "isFinal": false,
            "isEnabled": true
          },
          {
            "id": "interview",
            "name": "Technical Interview",
            "isInitial": false,
            "isFinal": false,
            "isEnabled": true
          },
          {
            "id": "hired",
            "name": "Hired",
            "isInitial": false,
            "isFinal": true,
            "isEnabled": true
          }
        ],
        "actions": [
          {
            "id": "screen",
            "name": "Screen Application",
            "isEnabled": true,
            "fromStates": ["application_received"],
            "toState": "screening"
          },
          {
            "id": "invite_interview",
            "name": "Invite to Interview",
            "isEnabled": true,
            "fromStates": ["screening"],
            "toState": "interview"
          },
          {
            "id": "hire",
            "name": "Hire Candidate",
            "isEnabled": true,
            "fromStates": ["interview"],
            "toState": "hired"
          }
        ]
      }')
    
    blueprint_id=$(echo $blueprint_response | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "Created blueprint: $blueprint_id"
    
    echo "Step 2: Start workflow"
    workflow_response=$(curl -s -X POST $API_URL/workflows \
      -H "Content-Type: application/json" \
      -d "{\"blueprintId\": \"$blueprint_id\"}")
    
    workflow_id=$(echo $workflow_response | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
    echo "Started workflow: $workflow_id"
    
    echo "Step 3: Screen application"
    curl -s -X POST $API_URL/workflows/$workflow_id/execute \
      -H "Content-Type: application/json" \
      -d '{"actionId": "screen"}' > /dev/null
    echo "Application screened"
    
    echo "Step 4: Invite to interview"
    curl -s -X POST $API_URL/workflows/$workflow_id/execute \
      -H "Content-Type: application/json" \
      -d '{"actionId": "invite_interview"}' > /dev/null
    echo "Interview scheduled"
    
    echo "Step 5: Hire candidate"
    final_response=$(curl -s -X POST $API_URL/workflows/$workflow_id/execute \
      -H "Content-Type: application/json" \
      -d '{"actionId": "hire"}')
    echo "Final result:"
    echo $final_response
    echo
    ;;
    
  17)
    echo "Testing All Error Cases"
    echo "Error 1: Invalid blueprint creation"
    curl -s -X POST $API_URL/blueprints \
      -H "Content-Type: application/json" \
      -d '{"name": "Bad", "states": [], "actions": []}'
    echo
    
    echo "Error 2: Get non-existent blueprint"
    curl -s $API_URL/blueprints/fake-id
    echo
    
    echo "Error 3: Start workflow with invalid blueprint"
    curl -s -X POST $API_URL/workflows \
      -H "Content-Type: application/json" \
      -d '{"blueprintId": "fake-blueprint"}'
    echo
    
    echo "Error 4: Get non-existent workflow"
    curl -s $API_URL/workflows/fake-workflow-id
    echo
    
    echo "Error 5: Execute action on non-existent workflow"
    curl -s -X POST $API_URL/workflows/fake-workflow/execute \
      -H "Content-Type: application/json" \
      -d '{"actionId": "fake-action"}'
    echo
    ;;
    
  *)
    echo "Invalid pathway number. Please choose 1-17."
    ;;
esac