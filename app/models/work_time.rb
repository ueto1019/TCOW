class WorkTime < ApplicationRecord
    belongs_to :employee

    validate :valid_time

    private

    def valid_time
        if clock_in.present? && clock_out.present? && clock_in >= clock_out
            errors.add("")
        end
    end
end
