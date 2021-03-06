-- Fist part of script to sum customer contract value

--Create Variables

stage_table = {"incoming", "qualified"}
pagination_table = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20}

local pipeline_deal_scope = 0
local pipeline_deal_weighted_scope = 0

--Make calls to Base

for key,value in  pairs(stage_table) do
	local stage_key = value
	for key,value in  pairs(pagination_table) do
		local page_key = value
		local response = http.request {
		url = 'https://sales.futuresimple.com/api/v1/deals.json?',
		params = {
			page = page_key,
			stage = stage_key,	
			indexing = "true"	
			},
		headers = {
			['X-Pipejump-Auth']= 'YOUR KEY HERE',
			}
		}
		local JSON = json.parse(response.content)
		if response.content == "[]" then break end
		for key,value in pairs(JSON) do
				pipeline_deal_scope = pipeline_deal_scope + JSON[key].deal.scope
				pipeline_deal_weighted_scope = pipeline_deal_weighted_scope + JSON[key].deal.scope*(JSON[key].deal.estimated_win_likelihood*.01)		
		end
	end	
end

--Store for Part B
storage.pipeline_deal_scope = pipeline_deal_scope
storage.pipeline_deal_weighted_scope = pipeline_deal_weighted_scope

return "200"
