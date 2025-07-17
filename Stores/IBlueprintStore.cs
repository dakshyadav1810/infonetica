using InfoneticaWorkflowEngine.Models;

namespace InfoneticaWorkflowEngine.Stores;

public interface IBlueprintStore
{
    WorkflowBlueprint? GetById(string id);
    IEnumerable<WorkflowBlueprint> GetAll();
    void Add(WorkflowBlueprint blueprint);
}
