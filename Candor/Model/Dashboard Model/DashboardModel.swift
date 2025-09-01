//
//  dashboardModel.swift
//  Candor
//
//  Created by mac on 28/07/25.
//

import Foundation

struct DashboardResponse: Codable {
    let success: Bool
    let message: String
    let data: DashboardData?
}

struct DashboardData: Codable {
    let project_list: ProjectList
    let employee_list: EmployeeList
    let client_list: ClientList
    let project_lead_list: ProjectLeadList
    let candidate_lead_list: CandidateLeadList
}

struct ProjectList: Codable {
    let total_project: Int
    let complete_project: Int
    let running_project: Int
    let over_due_project: Int
}

struct EmployeeList: Codable {
    let total_employee: Int
    let active_employee: Int
    let inactive_employee: Int
    let on_termination_employee: Int
}

struct ClientList: Codable {
    let total_client: Int
}

struct ProjectLeadList: Codable {
    let total_project_lead: Int
    let open_project_lead: Int
    let confirm_sale_project_lead: Int
    let closed_project_lead: Int
}

struct CandidateLeadList: Codable {
    let total_candidate_lead: Int
    let open_candidate_lead: Int
    let todays_interview: Int
    let upcoming_interview: Int
}
