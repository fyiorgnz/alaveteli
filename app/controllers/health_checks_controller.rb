# -*- encoding : utf-8 -*-
class HealthChecksController < ApplicationController

  def index
    @health_checks = HealthChecks.all

    respond_to do |format|
        response_hash =  { :action => :index, :layout => false }
        format.html do
            render HealthChecks.ok? ? response_hash :
                                      response_hash.merge(:status => 500)
        end
        format.json { render json: { health_checks: HealthChecks.ok? } }
    end

  end

end
