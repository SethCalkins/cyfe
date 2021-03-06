--Second part of script to count opportunities (Base calls them Deals) in sales pipeline


--Create Variables

stage_table = {"quote", "custom1","custom2","custom3","closure"}
pagination_table = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20}

local pipeline_deal_count = storage.pipeline_deal_count


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
			pipeline_deal_count = pipeline_deal_count + 1
		end
	end	
end

--Create Data to Send to Cyfe

local pipeline_deal_count_table = {["data"] = {[1] = { ["Date"] = yesterday_cyfe, ["Active Deals"] = pipeline_deal_count } }, ["onduplicate"] = {["Active Deals"] = "replace"}, ["cumulative"] = {["Active Deals"] = "1"} }
local pipeline_deal_count_json = json.stringify(pipeline_deal_count_table)

-- Push Data to Cyfe

local push_pipeline_deal_count = http.request {
	method='post',
	url = 'CYFE +_WIDGET_PUSH_URL',
	data = pipeline_deal_count_json
}

return "200"
