class EmployeesController < ApplicationController
    before_action :set_employee, only: [:show, :edit, :update, :date]
    before_action :authenticate_admin!, only: [:edit, :update]
    before_action :ensure_employee, only: [:show, :date]

    def index
        @employees = Employee.all.order(created_at: :asc)
    end

    def show
        @date = @employee.work_times.select('DISTINCT year, month').order('year ASC, month ASC')
    end

    def date
        @year = params[:year]
        @month = params[:month]

        @work_times = @employee.work_times.where(year: @year, month: @month).order(clock_in: :asc)

        if @employee.break_time.present? && @employee.break_time > 0
            total_break_time = @employee.break_time * @work_times.count
            @total_worked_time = (@work_times.sum(:worked_time) / 60.0) - total_break_time
        else
            @total_worked_time = @work_times.sum(:worked_time) / 60.0
        end

        @income = @total_worked_time * @employee.wage
    end

    def edit
    end

    def update
        if @employee.update(employee_params)
            redirect_to employee_path(@employee.id), notice: '従業員情報を修正しました'
        else
            redirect_to employee_path(@employee.id), alert: '従業員情報を修正しました'
        end
    end

    private

    def set_employee
        @employee = Employee.find(params[:id])
    end

    def employee_params
        params.require(:employee).permit(:duty_time, :wage, :break_time, :email)
    end

    def ensure_employee
        unless admin_signed_in?
            if @employee.id != current_employee.id
                redirect_to employee_path(current_employee.id), alert: "不正なアクセス"
            end
        end
    end
end
