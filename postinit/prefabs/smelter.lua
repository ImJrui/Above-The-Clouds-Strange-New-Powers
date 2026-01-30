local AddPrefabPostInit = AddPrefabPostInit

GLOBAL.setfenv(1, GLOBAL)

local function postinit_fn(inst)
    if not TheWorld.ismastersim then
        return
    end

    local stewer = inst.components.stewer
    if stewer and stewer.ondonecooking then
        local donecookfn = stewer.ondonecooking
        local _ShowProduct, scope_fn, index = ToolUtil.GetUpvalue(donecookfn, "ShowProduct")
        if _ShowProduct then
            local ShowProduct = function(inst)
                _ShowProduct(inst)
				if not inst:HasTag("burnt") then
					local product = inst.components.stewer.product
                    if product and product == "messagebottleempty" or product == "ash" then
                        inst.AnimState:OverrideSymbol("swap_item", "pl_swap_items", product)
                    end
				end
            end
            debug.setupvalue(scope_fn, index, ShowProduct)
        end
    end
end

AddPrefabPostInit("smelter", postinit_fn)