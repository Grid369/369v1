import json
import uuid
import datetime

class Agent:
    def __init__(self, id, name, email, role, department, skills):
        self.id = id
        self.name = name
        self.email = email
        self.role = role
        self.department = department
        self.skills = skills
        self.performance_score = 0.0
        self.current_task = None
        self.status = 'available'
        
    def update_performance(self, task_success):
        adjustment = 0.1 if task_success else -0.05
        self.performance_score = max(0, min(10, self.performance_score + adjustment))

class AIManager:
    def __init__(self, organization_name="Global Innovation Solutions"):
        self.organization_name = organization_name
        self.agents = {}
        self.task_queue = []
        self.completed_tasks = []
        
    def register_agent(self, name, email, role, department, skills):
        agent_id = str(uuid.uuid4())
        agent = Agent(
            id=agent_id,
            name=name,
            email=email,
            role=role,
            department=department,
            skills=skills
        )
        self.agents[agent_id] = agent
        print(f"Registered agent: {name} (ID: {agent_id})")
        return agent_id
        
    def create_task(self, title, description, required_skills, priority=5):
        task_id = str(uuid.uuid4())
        task = {
            'id': task_id,
            'title': title,
            'description': description,
            'required_skills': required_skills,
            'priority': priority,
            'status': 'pending',
            'created_at': datetime.datetime.now().isoformat(),
            'assigned_agent': None
        }
        self.task_queue.append(task)
        print(f"Created task: {title}")
        return task_id
        
    def assign_task(self, task_id):
        task = next((t for t in self.task_queue if t['id'] == task_id), None)
        if not task:
            print(f"Task {task_id} not found")
            return False

        best_agents = [
            agent for agent in self.agents.values()
            if (agent.status == 'available' and
                all(skill in agent.skills for skill in task['required_skills']))
        ]

        if best_agents:
            best_agent = max(best_agents, key=lambda a: a.performance_score)
            task['assigned_agent'] = best_agent.id
            best_agent.current_task = task_id
            best_agent.status = 'busy'
            print(f"Assigned task {task_id} to {best_agent.name}")
            return True
        
        print(f"No suitable agent found for task {task_id}")
        return False
        
    def complete_task(self, task_id, success=True):
        task = next((t for t in self.task_queue if t['id'] == task_id), None)
        if task:
            task['status'] = 'completed' if success else 'failed'
            
            if task['assigned_agent']:
                agent = self.agents[task['assigned_agent']]
                agent.update_performance(success)
                agent.status = 'available'
                agent.current_task = None

            self.completed_tasks.append(task)
            self.task_queue.remove(task)
            print(f"Task {task_id} completed")

    def generate_report(self):
        report = {
            'organization': self.organization_name,
            'timestamp': datetime.datetime.now().isoformat(),
            'agents': len(self.agents),
            'pending_tasks': len(self.task_queue),
            'completed_tasks': len(self.completed_tasks)
        }
        return report

# Usage example
if __name__ == "__main__":
    # Create manager
    manager = AIManager("TechCorp")
    
    # Register agents
    dev_agent = manager.register_agent(
        "Alex Smith", 
        "alex@example.com", 
        "Developer", 
        "Engineering", 
        ["python_programming", "api_development"]
    )
    
    analyst_agent = manager.register_agent(
        "Maria Garcia", 
        "maria@example.com", 
        "Data Analyst", 
        "Analytics", 
        ["data_analysis", "machine_learning"]
    )
    
    # Create tasks
    api_task = manager.create_task(
        "Build REST API", 
        "Create a RESTful API for customer data", 
        ["python_programming", "api_development"],
        priority=8
    )
    
    ml_task = manager.create_task(
        "Create ML Model", 
        "Develop prediction model for sales data", 
        ["data_analysis", "machine_learning"],
        priority=9
    )
    
    # Assign and complete tasks
    manager.assign_task(api_task)
    manager.assign_task(ml_task)
    manager.complete_task(api_task)
    
    # Generate report
    report = manager.generate_report()
    print(json.dumps(report, indent=2))
