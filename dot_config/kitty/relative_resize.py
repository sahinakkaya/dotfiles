"""Directional resizing for Kitty panes, called by pass_keys.py."""


def relative_resize_window(direction, amount, target_window_id, boss):
    window = boss.window_id_map.get(target_window_id)
    if window is None:
        return

    neighbors = boss.active_tab.current_layout.neighbors_for_window(
        window, boss.active_tab.windows
    )

    left_neighbors = neighbors.get('left')
    right_neighbors = neighbors.get('right')
    top_neighbors = neighbors.get('top')
    bottom_neighbors = neighbors.get('bottom')

    # has a neighbor on both sides
    if direction == 'left' and (left_neighbors and right_neighbors):
        boss.active_tab.resize_window('narrower', amount)
    # only has left neighbor
    elif direction == 'left' and left_neighbors:
        boss.active_tab.resize_window('wider', amount)
    # only has right neighbor
    elif direction == 'left' and right_neighbors:
        boss.active_tab.resize_window('narrower', amount)

    # has a neighbor on both sides
    elif direction == 'right' and (left_neighbors and right_neighbors):
        boss.active_tab.resize_window('wider', amount)
    # only has left neighbor
    elif direction == 'right' and left_neighbors:
        boss.active_tab.resize_window('narrower', amount)
    # only has right neighbor
    elif direction == 'right' and right_neighbors:
        boss.active_tab.resize_window('wider', amount)

    # has a neighbor above and below
    elif direction == 'up' and (top_neighbors and bottom_neighbors):
        boss.active_tab.resize_window('shorter', amount)
    # only has top neighbor
    elif direction == 'up' and top_neighbors:
        boss.active_tab.resize_window('taller', amount)
    # only has bottom neighbor
    elif direction == 'up' and bottom_neighbors:
        boss.active_tab.resize_window('shorter', amount)

    # has a neighbor above and below
    elif direction == 'down' and (top_neighbors and bottom_neighbors):
        boss.active_tab.resize_window('taller', amount)
    # only has top neighbor
    elif direction == 'down' and top_neighbors:
        boss.active_tab.resize_window('shorter', amount)
    # only has bottom neighbor
    elif direction == 'down' and bottom_neighbors:
        boss.active_tab.resize_window('taller', amount)

