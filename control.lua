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

local function ConditionLabel(condition)
  return string.format('{%s|\\%s|%s}',
    condition.first_signal.name,
    condition.comparator,
    condition.second_signal and condition.second_signal.name or condition.constant
  )
end

local function InserterLabel(control)

  local condlabel = "No Condition"
  if control.circuit_mode_of_operation == defines.control_behavior.inserter.circuit_mode_of_operation.enable_disable then
    condlabel = ConditionLabel(control.circuit_condition.condition)
  elseif control.circuit_mode_of_operation == defines.control_behavior.inserter.circuit_mode_of_operation.set_filters then
    condlabel = "Set Filters"
  end

  local readlabel = "Off"
  if control.circuit_read_hand_contents then
    if control.circuit_hand_read_mode == defines.control_behavior.inserter.hand_read_mode.pulse then
      readlabel = "Pulse"
    elseif control.circuit_hand_read_mode == defines.control_behavior.inserter.hand_read_mode.pulse then
      readlabel = "Hold"
    end
  end

  local stacklabel = ''
  if control.circuit_set_stack_size then
    stacklabel = "|{Set Stack Size|"
    stacklabel = stacklabel .. (control.circuit_stack_control_signal and control.circuit_stack_control_signal.name)
    stacklabel = stacklabel ..  "}"
  end

  return string.format('%s|{Read Hand|%s}%s',
    condlabel,
    readlabel,
    stacklabel
  )
end

local function RoboportLabel(control)
  if control.mode_of_operations == defines.control_behavior.roboport.circuit_mode_of_operation.read_logistics then
    return "Read Logistics"
  elseif control.mode_of_operations == defines.control_behavior.roboport.circuit_mode_of_operation.read_robot_stats then
    return string.format('{Avail. Log.|%s}|{Total Log.|%s}|{Avail. Con.|%s}|{Total Con.|%s}',
      control.available_logistic_output_signal and control.available_logistic_output_signal.name,
      control.total_logistic_output_signal and control.total_logistic_output_signal.name,
      control.available_construction_output_signal and control.available_construction_output_signal.name,
      control.total_construction_output_signal and control.total_construction_output_signal.name
    )
  end
end

local function LogisticContainerLabel(control)
  if control.circuit_mode_of_operation == defines.control_behavior.logistic_container.circuit_mode_of_operation.send_contents then
    return "Read Contents"
  elseif control.circuit_mode_of_operation == defines.control_behavior.logistic_container.circuit_mode_of_operation.set_requests then
    return "Set Requests"
  end
end

local function EntityLabel(ent)
  local control = ent.get_or_create_control_behavior()
  if not control then
    return string.format('{%s|%s}',
      ent.type,
      ent.name
    )
  elseif control.type == defines.control_behavior.type.container or
    control.type == defines.control_behavior.type.storage_tank then
    return string.format('{%s|%s}',
      ent.name,
      "Read Contents"
    )
  elseif control.type == defines.control_behavior.type.generic_on_off then
    return string.format('{%s|%s}',
      ent.name,
      ConditionLabel(control.circuit_condition.condition)
    )
  elseif control.type == defines.control_behavior.type.inserter then
    return string.format('{%s|%s}',
      ent.name,
      InserterLabel(control)
    )
  elseif control.type == defines.control_behavior.type.lamp then
    return string.format('{%s|{Use Colors|%s}|%s}',
      ent.name,
      control.use_colors and "On" or "Off",
      ConditionLabel(control.circuit_condition.condition)
    )
  elseif control.type == defines.control_behavior.type.logistic_container then
    return string.format('{%s|%s}',
      ent.name,
      LogisticContainerLabel(control)
    )
  elseif control.type == defines.control_behavior.type.roboport then
    return string.format('{%s|%s}',
      ent.name,
      RoboportLabel(control)
    )
  elseif control.type == defines.control_behavior.type.train_stop then
    return string.format('{%s|{Send to Train|%s}|{Read from Train|%s}%s}',
      ent.name,
      control.send_to_train and "On" or "Off",
      control.read_from_train and "On" or "Off",
      control.enable_disable and ('|' .. ConditionLabel(control.circuit_condition.condition)) or ''
    )
  elseif control.type == defines.control_behavior.type.decider_combinator then
    return string.format('<1>\\>|{%s|%s|{%s|%s}}|<2>\\>',
      ent.name,
      ConditionLabel(control.parameters.parameters),
      control.parameters.parameters.output_signal.name,
      control.parameters.parameters.copy_count_from_input and "=input" or "=1"
    )
  elseif control.type == defines.control_behavior.type.arithmetic_combinator then
    local op = control.parameters.parameters.operation
    if op == ">>" then op = "\\>\\>" end
    if op == "<<" then op = "\\<\\<" end
    return string.format('<1>\\>|{%s|{%s|%s|%s}|%s}|<2>\\>',
      ent.name,
      control.parameters.parameters.first_signal.name,
      op,
      control.parameters.parameters.second_signal and control.parameters.parameters.second_signal.name or control.parameters.parameters.constant,
      control.parameters.parameters.output_signal.name
    )
  elseif control.type == defines.control_behavior.type.constant_combinator then
    return string.format('{%s|%s|%s}',
      ent.name,
      control.enabled and "On" or "Off",
      table.concat(CCDataLabels(control),"|")
    )
  elseif control.type == defines.control_behavior.type.transport_belt then
    local label = ''
    if control.enable_disable then
      label = label .. '|' .. ConditionLabel(control.circuit_condition.condition)
    end
    if control.read_contents then
      label = label .. string.format('|{Read Mode|%s}',
      control.read_contents_mode == defines.control_behavior.transport_belt.content_read_mode.pulse and "Pulse" or "Hold"
      )
    end
    return string.format('{%s%s}',
      ent.name,
      label
    )
  elseif control.type == defines.control_behavior.type.accumulator then
    return string.format('{%s|{Read charge level|%s}}',
      ent.name,
      control.output_signal and control.output_signal.name
    )
  --elseif control.type == defines.control_behavior.type.rail_signal then
    --TODO: rail signals report nothing...
  elseif control.type == defines.control_behavior.type.wall then
    local label = ''
    if control.open_gate then
      label = label .. '|' .. ConditionLabel(control.circuit_condition.condition)
    end
    if control.read_sensor then
      label = label .. string.format('|{Read Sensor|%s}',
        control.output_signal and control.output_signal.name
        )
    end
    return string.format('{%s%s}',
      ent.name,
      label
    )
  elseif control.type == defines.control_behavior.type.mining_drill then
    local label = ''
    if control.circuit_enable_disable then
      label = label .. '|' .. ConditionLabel(control.circuit_condition.condition)
    end
    if control.circuit_read_resources then
      label = label .. string.format('|{Read Resources|%s}',
      control.resource_read_mode == defines.control_behavior.mining_drill.resource_read_mode.this_miner and "This Miner" or "Entire Patch"
      )
    end
    return string.format('{%s%s}',
      ent.name,
      label
    )
  elseif control.type == defines.control_behavior.type.programmable_speaker then
    local label = '{' .. ent.name

    label = label .. '|{Volume|' .. ent.parameters.playback_volume .. '}'

    if ent.parameters.playback_globally or ent.parameters.allow_polyphony then
      label = label .. '|{'

      if ent.parameters.playback_globally then
        label = label .. 'Global'
      end
      if ent.parameters.allow_polyphony then
        if ent.parameters.playback_globally then
          label = label .. '|'
        end
        label = label .. 'Polyphony'
      end
      label = label .. '}'
    end

    local instruments = ent.prototype.instruments

    if control.circuit_parameters.signal_value_is_pitch then
      label = label .. string.format('|{%s|%s}',
        instruments[control.circuit_parameters.instrument_id+1] and instruments[control.circuit_parameters.instrument_id+1].name or control.circuit_parameters.instrument_id,
        control.circuit_condition.condition.first_signal and control.circuit_condition.condition.first_signal.name
      )
    else
      label = label .. string.format('|{%s|%s}',
        instruments[control.circuit_parameters.instrument_id+1] and instruments[control.circuit_parameters.instrument_id+1].name or control.circuit_parameters.instrument_id,
        instruments[control.circuit_parameters.instrument_id+1] and instruments[control.circuit_parameters.instrument_id+1].notes[control.circuit_parameters.note_id+1] or control.circuit_parameters.note_id
      )
      label = label .. '|' .. ConditionLabel(control.circuit_condition.condition)
    end

    if ent.alert_parameters and ent.alert_parameters.show_alert then
      label = label .. string.format('|{%s|%s|%s}',
        ent.alert_parameters.show_on_map and "Alert|On Map" or "Alert",
        ent.alert_parameters.icon_signal_id and ent.alert_parameters.icon_signal_id.name,
        ent.alert_parameters.alert_message
      )
    end
    label = label .. '}'
    return label
  else
    return string.format('{%s|%s}',
      ent.type,
      ent.name
    )
  end
end

local colors = {
  [defines.wire_type.red] = "red",
  [defines.wire_type.green] = "green"
}

local function WirePort(ent,port)
  if ent.type == "arithmetic-combinator" or ent.type == "decider-combinator" then
    local ports={"w","e"}
    return ports[port]
  else
    return "_"
  end
end

local function GraphCombinators(ents)
  local gv = {
    "graph combinators {",
    --'graph[overlap="portho" splines="spline" layout="fdp" sep=0.5];',
    'graph[overlap="portho" splines="spline" sep=0.5];',
  }
  local donelist = {}
  for _,ent in pairs(ents) do
    if ent.circuit_connection_definitions and #ent.circuit_connection_definitions > 0 then
      gv[#gv+1] = string.format('%d [shape=record label="%s" pos="%d,%d"];',
        ent.unit_number,
        EntityLabel(ent),
        ent.position.x,
        ent.position.y
      )

      for _,conn in pairs(ent.circuit_connection_definitions) do
        if not (
          donelist[conn.target_entity.unit_number] or
          ent == conn.target_entity and conn.target_circuit_id == 1
          ) then
          gv[#gv+1] = string.format('%d:%d -- %d:%d [color=%s headport=%s tailport=%s];',
            ent.unit_number,conn.source_circuit_id,
            conn.target_entity.unit_number,conn.target_circuit_id,
            colors[conn.wire],
            WirePort(conn.target_entity,conn.target_circuit_id),
            WirePort(ent,conn.source_circuit_id)
          )
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
