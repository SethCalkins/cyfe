--Script designed to call Base CRM and identify newly created deals in the sales pipeline

--Create Variables

stage_table = {"incoming"}
pagination_table = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20}

local pipeline_lead_count = 0
local date = os.date("%d") - 1
local yesterday = string.format(os.date("%Y-%m-").."%02d",date)
local yesterday_cyfe = string.format(os.date("%Y%m").."%02d",date)

--Make calls to Base

for key,value in  pairs(stage_table) do
	local stage_key = value
	for key,value in  pairs(pagination_table) do
		local page_key = value
		local response = http.request {
		url = 'https://sales.futuresimple.com/api/v1/deals.json?',
		params = {
			page = page_key,
			stage = stage_key	
			},
		headers = {
			['X-Pipejump-Auth']= 'YOUR_KEY',
			}
		}
		local JSON = json.parse(response.content)
		if response.content == "[]" then break end
		for key,value in pairs(JSON) do
      		local date_added = JSON[key].deal.added_on
			if tonumber(string.sub(JSON[key].deal.added_at,12,13)) < 5 then
				date_added = string.sub(date_added,1,9) .. string.sub(date_added,10,10) - 1
			end	
			if date_added == yesterday then	
				pipeline_lead_count = pipeline_lead_count + 1
			end		
		end
	end	
end

--Create Data to Send to Cyfe

local pipeline_lead_count_table = {["data"] = {[1] = { ["Date"] = yesterday_cyfe, ["Leads"] = pipeline_lead_count } }, ["onduplicate"] = {["Leads"] = "replace"}, ["cumulative"] = {["Leads"] = "1"} }
local pipeline_lead_count_json = json.stringify(pipeline_lead_count_table)

-- Push Data to Cyfe

local push_pipeline_deal_count = http.request {
	method='post',
	url = 'YOUR_WIDGET_PUSH_URL',
	data = pipeline_lead_count_json
}

return "200"
