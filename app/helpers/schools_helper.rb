module SchoolsHelper
      # Array mapping state name to state name
      # @return The array of state names
      def us_states
            [
                  ['All Schools', ''],
                  ['Alabama', 'Alabama'],
                  ['Alaska', 'Alaska'],
                  ['Arizona', 'Arizona'],
                  ['Arkansas', 'Arkansas'],
                  ['California', 'California'],
                  ['Colorado', 'Colorado'],
                  ['Connecticut', 'Connecticut'],
                  ['Delaware', 'Delaware'],
                  ['District of Columbia', 'District of Columbia'],
                  ['Florida', 'Florida'],
                  ['Georgia', 'Georgia'],
                  ['Hawaii', 'Hawaii'],
                  ['Idaho', 'Idaho'],
                  ['Illinois', 'Illinois'],
                  ['Indiana', 'Indiana'],
                  ['Iowa', 'Iowa'],
                  ['Kansas', 'Kansas'],
                  ['Kentucky', 'Kentucky'],
                  ['Louisiana', 'Louisiana'],
                  ['Maine', 'Maine'],
                  ['Maryland', 'Maryland'],
                  ['Massachusetts', 'Massachusetts'],
                  ['Michigan', 'Michigan'],
                  ['Minnesota', 'Minnesota'],
                  ['Mississippi', 'Mississippi'],
                  ['Missouri', 'Missouri'],
                  ['Montana', 'Montana'],
                  ['Nebraska', 'Nebraska'],
                  ['Nevada', 'Nevada'],
                  ['New Hampshire', 'New Hampshire'],
                  ['New Jersey', 'New Jersey'],
                  ['New Mexico', 'New Mexico'],
                  ['New York', 'New York'],
                  ['North Carolina', 'North Carolina'],
                  ['North Dakota', 'North Dakota'],
                  ['Ohio', 'Ohio'],
                  ['Oklahoma', 'Oklahoma'],
                  ['Oregon', 'Oregon'],
                  ['Pennsylvania', 'Pennsylvania'],
                  ['Puerto Rico', 'Puerto Rico'],
                  ['Rhode Island', 'Rhode Island'],
                  ['South Carolina', 'South Carolina'],
                  ['South Dakota', 'South Dakota'],
                  ['Tennessee', 'Tennessee'],
                  ['Texas', 'Texas'],
                  ['Utah', 'Utah'],
                  ['Vermont', 'Vermont'],
                  ['Virginia', 'Virginia'],
                  ['Washington', 'Washington'],
                  ['West Virginia', 'West Virginia'],
                  ['Wisconsin', 'Wisconsin'],
                  ['Wyoming', 'Wyoming']
            ]
      end

      def school_website_url(school)
            return "http://#{school.website.gsub('http://', '').gsub('>', '')}"
      end

      def school_categories
            return ['Four-Year', 'Two-Year']
      end

      def alpha_array
            ("A".."Z").to_a
      end
end
