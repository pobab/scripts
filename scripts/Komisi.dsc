Komisi_Listener:
    type: world
    events:
        on player fishes entity:
        - stop if:<context.xp.is_less_than_or_equal_to[0]>
        - define target <context.item.material.name>
        - run Komisi_progressTask def.player:<player> def.uuid:<player.proc[Komisi_uuidTask].context[fisherman]> def.target:<[target]> def.value:+1


Komisi_newTask:
    type: task
    definitions: player|entity
    script:
    - define quantity   <util.random.int[1].to[16]>
    - define profession <list[fisherman].random>
    # - define profession <list[fisherman|butcher|shepherd].random>

    - define uuid <util.random_uuid>
    - if <[entity].exists>:
        - define uuid <[entity].uuid>
        - define profession <[entity].profession> if:<[entity].profession.exists>
        - flag <[player]> komisi.<[uuid]>.entity:<[entity].entity_type>

    - if <[profession]> == fisherman:
        - define target <list[cod|salmon|pufferfish|tropical_fish].random>

    - flag <[player]> komisi.<[uuid]>.<[profession]>.<[target]>.recent:0
    - flag <[player]> komisi.<[uuid]>.<[profession]>.<[target]>.quantity:<[quantity]>


Komisi_uuidTask:
    type: procedure
    definitions: player|profession
    script:
    - determine <list> if:!<[player].has_flag[komisi]>
    - determine <[player].flag[komisi].keys> if:!<[profession].exists>

    - define task <[player].flag[komisi].deep_keys.filter[contains_text[<[profession]>]]>
    - foreach <[task]>:
        - define uuid:->:<[value].split[.].first>
    - determine <[uuid].deduplicate> if:<[uuid].exists>


Komisi_getTask:
    type: procedure
    definitions: player|uuid|data
    script:
    - determine null if:!<[player].has_flag[komisi]>
    - determine <[player].flag[komisi.<[uuid]>].keys.first>                         if:<[data].equals[profession]>
    - define profession <[player].proc[<script.name>].context[<[uuid]>|profession]>
    - determine <[player].flag[komisi.<[uuid]>.<[profession]>].keys.first>          if:<[data].equals[target]>
    - define target     <[player].proc[<script.name>].context[<[uuid]>|target]>
    - determine <[player].flag[komisi.<[uuid]>.<[profession]>.<[target]>.recent]>   if:<[data].equals[recent]>
    - determine <[player].flag[komisi.<[uuid]>.<[profession]>.<[target]>.quantity]> if:<[data].equals[quantity]>


Komisi_progressTask:
    type: task
    definitions: player|uuid|target|value
    script:
    - foreach <[uuid]> as:id:
        - define profession <[player].flag[komisi.<[id]>].keys.first>
        - define object     <[player].flag[komisi.<[id]>.<[profession]>].keys.first>
        - foreach next if:!<[object].equals[<[target]>]>

        - define recent <[player].flag[komisi.<[id]>.<[profession]>.<[object]>.recent]>
        - define goal   <[player].flag[komisi.<[id]>.<[profession]>.<[object]>.quantity]>
        - if <[value].contains_text[+]>:
            # todo: bikin fungsi ketika komisi completed
            - define value  <[value].after[+]>
            - foreach next if:<[recent].is_more_than_or_equal_to[<[goal]>]>
            - flag <[player]> komisi.<[id]>.<[profession]>.<[object]>.recent:<[recent].add[<[value]>]>
            - narrate progress_<&e><[profession]>_<&b><[object]>_<&a><[value]>_<&c><[recent]>

