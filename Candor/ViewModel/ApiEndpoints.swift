//
//  basicApiModel.swift
//  Candor
//
//  Created by mac on 24/07/25.
//

import Foundation


struct APIEndpoints{
    static let baseURL = "http://159.65.145.9:3000/api/v1"
    
    ///Login
    static var login : String { return "\(baseURL)/login" }
    static var loggedInUserProfile : String { return "\(baseURL)/get-profile"}
    static var forgotPassword : String {return "\(baseURL)/update-employee-password"}
    static var employeesList : String{ return "\(baseURL)/get-employees?page=1&limit=15"}
    ///dashboard tab
    static var dashboard : String { return "\(baseURL)/get-dashboard-count" }
    ///project tab
    static var projectsList: String { return "\(baseURL)/get-project" }
    static var addProject : String { return "\(baseURL)/add-project" }
    static var updateProject: String { return "\(baseURL)/update-project"}
    static var deleteProject: String { return "\(baseURL)/delete-project" }
    ///emplyee tab
    static var addEmployee : String { return "\(baseURL)/add-user" }
    static var getEmployeeInfo : String { return "\(baseURL)/get-employee-by-id" }
    static var editEmployee : String { return "\(baseURL)/edit-employee" }
    static var changeEmployeePassword : String { return "\(baseURL)/update-profile" }
    static var changeEmployeeStatus : String { return "\(baseURL)/update-employee-status"} // use this part when:- after changing the task status the after reloading the task index will change so at that use this
    
    ///tasks in projects
    static var createTaskInTable: String { return "\(baseURL)/create-task" }
    static var getTasksInTable: String { return "\(baseURL)/get-tasks" }
    static var changeTaskProgressIndex: String { return "\(baseURL)/update-project-task-index"}
    static var updateTask: String { return "\(baseURL)/update-task"}
    static var deleteTask: String { return "\(baseURL)/delete-task"}
    
    //check where to use this
    ///in cell task creation
    static var getUserTasks: String { return "\(baseURL)/get-user-tasks"} // make changes in the api and use it with the i button on the top right
    
    /// section names
    static var GetProjectTaskSectionsName: String { return "\(baseURL)/task-status/get-project-task-status"}
    static var AddProjectTaskSectionsName: String { return "\(baseURL)/task-status/add-project-task-status"}
    static var DeleteProjectTaskSectionsName: String { return "\(baseURL)/task-status/delete-project-task-status"}
    
    ///inner tasks
    static var GetInnerTasks: String { return "\(baseURL)/get-task"}
    static var UpdateInnerTasks: String { return "\(baseURL)/update-task"}
    //delete task
    
    ///subtasks
    static var CreateSubTasks: String { return "\(baseURL)/create-sub-task"}
    static var GetSubTasks: String { return "\(baseURL)/get-sub-task"}
    static var UpdateSubTasks: String { return "\(baseURL)/update-sub-task"}
    
    ///comments and activity
    static var GetActivity: String { return "\(baseURL)/get-task-activity"}
    static var GetComments: String { return "\(baseURL)/get-task-comments"}
    static var AddComments: String { return "\(baseURL)/send-task-comment"}
    static var DeleteComments: String { return "\(baseURL)/delete-task-comments"}
    
    ///documents in projects
    static var uploadProjectDocument: String { return "\(baseURL)/upload-project-document" }
    static var getProjectDocuments: String { return "\(baseURL)/get-project-document"}
    static var deleteProjectDocument: String { return "\(baseURL)/delete-project-document"}
    
    ///members in projects
    static var getProjectMembers: String { return "\(baseURL)/get-project-members"}
    static var addMemberInProject: String { return "\(baseURL)/add-project-member"}
    static var getEmployeeDropDown: String { return "\(baseURL)/get-employee-list-for-project-member"}
    static var removeMemberFromProject: String { return "\(baseURL)/remove-project-member"}
    ///notes in projects
    static var addNoteInProject: String { return "\(baseURL)/add-project-note"}
    static var fetchNotes: String { return "\(baseURL)/get-project-notes"}
    static var updateNote: String { return "\(baseURL)/update-project-note"}
    static var deleteNote: String { return "\(baseURL)/delete-project-note"}
    
    ///api files check
}
