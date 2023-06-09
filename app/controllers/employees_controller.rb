class EmployeesController < ApplicationController
    before_action :set_employee, only: [:show, :edit, :update, :date, :destroy]
    before_action :authenticate_admin!, only: [:index, :edit, :update]
    before_action :ensure_employee, only: [:show, :date]

    def index
        # @employees = Employee.all.order(created_at: :asc)
        @employees = Employee.where("name LIKE ? OR employee_id LIKE ? ", 
                            "%#{params[:search]}%", "%#{params[:search]}%").order(created_at: :asc)
    end

    def show
        @date = @employee.work_times.select('DISTINCT year, month').order('year ASC, month ASC')
    end

    def date
        @year = params[:year]
        @month = params[:month]

        @work_times = @employee.work_times.where(year: @year, month: @month).order(clock_in: :asc)
        @work_day_count = @work_times.count

        if @employee.break_time.present? && @employee.break_time > 0
            actual_work_time = []
            @work_times.each do |time|
                if time.worked_time
                    if time.worked_time > @employee.break_time * 60.0
                        actual_work_time << time.worked_time - (@employee.break_time * 60.0)
                    else
                        actual_work_time << time.worked_time
                    end
                end
            end

            @total_hour = actual_work_time.sum / 60.0
            @total_minute = actual_work_time.sum.round
        else
            @total_hour = @work_times.sum(:worked_time) / 60.0
            @total_minute = @work_times.sum(:worked_time).round
        end

        if @employee.wage.present?
            wage_per_minute = @employee.wage / 60.0
            @income = (wage_per_minute * @total_minute).round
        end
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

    def destroy
        @employee.destroy
        redirect_to employees_path, notice: "従業員を削除しました"
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
            if employee_signed_in?
                if @employee.id != current_employee.id
                    redirect_to employee_path(current_employee.id), alert: "不正なアクセス"
                end
            else
                redirect_to root_path, alert: "不正なアクセス"
            end
        end
    end
end
