class WorkTimesController < ApplicationController
    before_action :authenticate_admin!, only: [:edit, :update]
    before_action :set_clock, only: [:clock_in, :clock_out]
    before_action :authenticate_employee!, only: [:clock_in, :clock_out]
    before_action :set_work_time, only: [:edit, :update]

    def clock_in
        if @latest_time && @latest_time.clock_out.nil?
            new_clock_in("semi_valid")
        else
            new_clock_in("valid")
        end
    end

    def clock_out
        if @latest_time && @latest_time.clock_out.nil?
            @latest_time.update(clock_out: Time.zone.now, worked_time: ((Time.zone.now - @latest_time.clock_in) / 60.0).round(2))
            redirect_to employee_menus_path, notice: '退勤しました。'
        else
            current_time = Time.zone.now
            clock_out_info = WorkTime.create(employee_id: current_employee.id, clock_out: current_time, year: current_time.year, month: current_time.month)
            redirect_to employee_menus_path, alert: '退勤しました。本日の出勤時刻が記録されていないので、管理者に連絡してください！'
        end
    end

    def edit
    end

    def update
        @current_employee = @work_time.employee

        if @work_time.update(work_time_params)
            worked_time = ((@work_time.clock_out - @work_time.clock_in) / 60.0).round(2)
            year = @work_time.clock_in.year
            month = @work_time.clock_in.month
            @work_time.update(worked_time: worked_time, year: year, month: month)
            redirect_to employee_path(@current_employee.id), notice: '打刻時間を修正しました'
        else
            redirect_to edit_work_time_path(@work_time.id), alert: '変更内容に誤りがあります'
        end
    end

    private

    def set_clock
        current_employee_time = WorkTime.where(employee_id: current_employee.id)
        @latest_time = current_employee_time.order(id: :desc).first
    end

    def set_work_time
        @work_time = WorkTime.find(params[:id])
    end

    def work_time_params
        params.require(:work_time).permit(:clock_in, :clock_out)
    end

    def new_clock_in(status)
        current_time = Time.zone.now
        WorkTime.create(employee_id: current_employee.id, clock_in: current_time, year: current_time.year, month: current_time.month)
        if status == "valid"
            redirect_to employee_menus_path, notice: '出勤しました。'
        else
            redirect_to employee_menus_path, alert: '出勤しました。前回の退勤打刻が記録されていないので、管理者に連絡してください！'
        end
    end
end
