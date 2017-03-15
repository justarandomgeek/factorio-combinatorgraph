local function CCDataLabels(control)
  local labels = {}
  for _,param in pairs(control.parameters.parameters) do
    if param.signal.name then
      labels[#labels+1] = string.format("{%s|%d}",
        param.signal.name,
        param.count
      )
    end
  end
  return labels
end

local function EntityLabel(ent)
  local control = ent.get_or_create_control_behavior()
  if ent.type == "arithmetic-combinator" then
    return string.format('<1>|{%s|{%s|%s|%s}|%s}|<2>',
      ent.name,
      control.parameters.parameters.first_signal.name,
      control.parameters.parameters.operation,
      control.parameters.parameters.second_signal and control.parameters.parameters.second_signal.name or control.parameters.parameters.constant,
      control.parameters.parameters.output_signal.name
    )
  elseif ent.type == "decider-combinator" then
    return string.format('<1>|{%s|{%s|\\%s|%s}|{%s|%s}}|<2>',
      ent.name,
      control.parameters.parameters.first_signal.name,
      control.parameters.parameters.comparator,
      control.parameters.parameters.second_signal and control.parameters.parameters.second_signal.name or control.parameters.parameters.constant,
      control.parameters.parameters.output_signal.name,
      control.parameters.parameters.copy_count_from_input and "=input" or "=1"
    )
  elseif ent.type == "constant-combinator" then
    return string.format('{%s|%s|%s}',
      ent.name,
      control.enabled and "On" or "Off",
      table.concat(CCDataLabels(control),"|")
    )
  else
    return ent.type
  end
end

local colors = {
  [defines.wire_type.red] = "red",
  [defines.wire_type.green] = "green"
}

local function GraphCombinators(ents)
  local gv = {
    "graph combinators {",
    "graph[ranksep=1];",
  }
  local donelist = {}
  for _,ent in pairs(ents) do
    if ent.circuit_connection_definitions and #ent.circuit_connection_definitions > 0 then
      gv[#gv+1] = string.format('%d [shape=record label="%s"];',ent.unit_number,EntityLabel(ent))

      for _,conn in pairs(ent.circuit_connection_definitions) do
        if not (
          donelist[conn.target_entity.unit_number] or
          ent == conn.target_entity and conn.target_circuit_id == 1
          ) then
          gv[#gv+1] = string.format('%d:%d -- %d:%d [color=%s];',
            ent.unit_number,conn.source_circuit_id,
            conn.target_entity.unit_number,conn.target_circuit_id,
            colors[conn.wire])
        end
      end
    end

    donelist[ent.unit_number] = true
  end
  gv[#gv+1] = "}"
  game.write_file("combinatorgraph.gv",table.concat(gv,'\n'))
end



script.on_event(defines.events.on_player_selected_area, function(event)
  if event.item == "combinatorgraph-tool" then
    GraphCombinators(event.entities)
  end
end)

script.on_event(defines.events.on_player_alt_selected_area, function(event)
  if event.item == "combinatorgraph-tool" then
    GraphCombinators(event.entities)
  end
end)
