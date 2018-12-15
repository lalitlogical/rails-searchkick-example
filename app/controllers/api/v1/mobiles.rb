module API
  module V1
    class Mobiles < Grape::API
      include API::V1::Defaults

      resource :mobiles do
        desc "mobiles listing"
        get "", root: "mobiles" do
          @mobile_phones = MobilePhone._search(params)
          render_collection(@mobile_phones, MobileSerializer)
        end
      end
    end
  end
end
