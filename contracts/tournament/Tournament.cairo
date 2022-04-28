# SPDX-License-Identifier: Apache-2.0
# StarKonquest smart contracts written in Cairo v0.1.0 (tournament/Tournament.cairo)

%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin
from starkware.cairo.common.bool import (TRUE, FALSE)
from starkware.cairo.common.math import (assert_lt, assert_nn, assert_not_zero)
from starkware.cairo.common.math_cmp import is_le
from starkware.cairo.common.uint256 import (Uint256, uint256_le)
from starkware.starknet.common.syscalls import (get_contract_address, get_caller_address)
from starkware.cairo.common.math import unsigned_div_rem
from starkware.cairo.common.alloc import alloc

# OpenZeppeling dependencies
from openzeppelin.access.ownable import (Ownable_initializer, Ownable_only_owner)
from openzeppelin.token.erc20.interfaces.IERC20 import IERC20
from openzeppelin.token.erc721.interfaces.IERC721 import IERC721

#from contracts.interfaces.ispace import ISpace
# TODO: remove this
@contract_interface
namespace ISpace:
    func play_game(
            rand_contract_address : felt, size : felt, turn_count : felt, max_dust : felt,
            ships_len : felt, ships : felt*) -> ():
    end
end

# ------------
# STORAGE VARS
# ------------

# Id of the tournament
@storage_var
func tournament_id_() -> (res : felt):
end

# Name of the tournament
@storage_var
func tournament_name_() -> (res : felt):
end

# ERC20 token address for the reward
@storage_var
func reward_token_address_() -> (res : felt):
end

# ERC721 token address for access control
@storage_var
func boarding_pass_token_address_() -> (res : felt):
end

# Random generator contract address
@storage_var
func rand_contract_address_() -> (res : felt):
end

# Space contract address
@storage_var
func space_contract_address_() -> (res : felt):
end

# Whether or not registration are open
@storage_var
func is_tournament_registration_open_() -> (res : felt):
end

# Number of ships per battle
@storage_var
func ships_per_battle_() -> (res : felt):
end

# Number of ships per tournament
@storage_var
func max_ships_per_tournament_() -> (res : felt):
end

# Size of the grid
@storage_var
func grid_size_() -> (res : felt):
end

# Turn count per battle
@storage_var
func turn_count_() -> (res : felt):
end

# Max dust in the grid at a given time
@storage_var
func max_dust_() -> (res : felt):
end

# Number of players
@storage_var
func player_count_() -> (res : felt):
end

# Player registered ship
@storage_var
func player_ship_(player_address: felt) -> (res : felt):
end

# Ship associated player
@storage_var
func ship_player_(ship_address: felt) -> (res : felt):
end

# Ship array
@storage_var
func ships_(index: felt) -> (ship_address : felt):
end

# Array of playing ships
@storage_var
func playing_ships_(index: felt) -> (ship_address : felt):
end
@storage_var
func playing_ships_count_() -> (res : felt):
end

# Array of winner ships
@storage_var
func winner_ships_(index: felt) -> (ship_address : felt):
end
@storage_var
func winner_ships_count_() -> (res : felt):
end

# Player scores
@storage_var
func player_score_(player_address: felt) -> (res : felt):
end

# Played battle count
@storage_var
func played_battle_count_() -> (res : felt):
end


# -----
# VIEWS
# -----
@view
func tournament_id{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (tournament_id : felt):
    let (tournament_id) = tournament_id_.read()
    return (tournament_id)
end

@view
func tournament_name{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (tournament_name : felt):
    let (tournament_name) = tournament_name_.read()
    return (tournament_name)
end

@view
func reward_token_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (reward_token_address : felt):
    let (reward_token_address) = reward_token_address_.read()
    return (reward_token_address)
end

@view
func boarding_pass_token_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (boarding_pass_token_address : felt):
    let (boarding_pass_token_address) = boarding_pass_token_address_.read()
    return (boarding_pass_token_address)
end

@view
func rand_contract_address{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (rand_contract_address : felt):
    let (rand_contract_address) = rand_contract_address_.read()
    return (rand_contract_address)
end

@view
func is_tournament_registration_open{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (is_tournament_registration_open : felt):
    let (is_tournament_registration_open) = is_tournament_registration_open_.read()
    return (is_tournament_registration_open)
end

@view
func reward_total_amount{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (reward_total_amount : Uint256):
    let (reward_token_address) = reward_token_address_.read()
    let (contract_address) = get_contract_address()
    let (reward_total_amount) = IERC20.balanceOf(
        contract_address=reward_token_address, account=contract_address
    )
    return (reward_total_amount)
end

@view
func ships_per_battle{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (ships_per_battle : felt):
    let (ships_per_battle) = ships_per_battle_.read()
    return (ships_per_battle)
end

@view
func max_ships_per_tournament{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (max_ships_per_tournament : felt):
    let (max_ships_per_tournament) = max_ships_per_tournament_.read()
    return (max_ships_per_tournament)
end

@view
func grid_size{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (grid_size : felt):
    let (grid_size) = grid_size_.read()
    return (grid_size)
end

@view
func turn_count{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (turn_count : felt):
    let (turn_count) = turn_count_.read()
    return (turn_count)
end

@view
func max_dust{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (max_dust : felt):
    let (max_dust) = max_dust_.read()
    return (max_dust)
end

@view
func player_count{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (player_count : felt):
    let (player_count) = player_count_.read()
    return (player_count)
end

@view
func player_ship{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    player_adress: felt
) -> (player_ship : felt):
    let (player_ship) = player_ship_.read(player_adress)
    return (player_ship)
end

@view
func ship_player{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ship_adress: felt
) -> (ship_player : felt):
    let (ship_player) = ship_player_.read(ship_adress)
    return (ship_player)
end

@view
func player_score{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    player_adress: felt
) -> (player_score : felt):
    let (player_score) = player_score_.read(player_adress)
    return (player_score)
end

@view
func played_battle_count{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (played_battle_count : felt):
    let (played_battle_count) = played_battle_count_.read()
    return (played_battle_count)
end

# -----
# CONSTRUCTOR
# -----

@constructor
func constructor{
        syscall_ptr: felt*, 
        pedersen_ptr: HashBuiltin*,
        range_check_ptr
    }(
        owner: felt,
        tournament_id: felt,
        tournament_name: felt,
        reward_token_address: felt,
        boarding_pass_token_address: felt,
        rand_contract_address: felt,
        space_contract_address: felt,
        ships_per_battle: felt,
        max_ships_per_tournament: felt,
        grid_size: felt,
        turn_count: felt,
        max_dust: felt
    ):
    Ownable_initializer(owner)
    tournament_id_.write(tournament_id)
    tournament_name_.write(tournament_name)
    reward_token_address_.write(reward_token_address)
    boarding_pass_token_address_.write(boarding_pass_token_address)
    rand_contract_address_.write(rand_contract_address)
    space_contract_address_.write(space_contract_address)
    ships_per_battle_.write(ships_per_battle)
    max_ships_per_tournament_.write(max_ships_per_tournament)
    grid_size_.write(grid_size)
    turn_count_.write(turn_count)
    max_dust_.write(max_dust)
    player_count_.write(0)
    return ()
end

# -----
# EXTERNAL FUNCTIONS
# -----

# Open tournament registration
@external
func open_tournament_registration{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (success: felt):
    #Ownable_only_owner()
    _only_tournament_registration_closed()
    is_tournament_registration_open_.write(TRUE)
    return (TRUE)
end

# Close tournament registration
@external
func close_tournament_registration{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
) -> (success: felt):
    #Ownable_only_owner()
    _only_tournament_registration_open()
    is_tournament_registration_open_.write(FALSE)
    return (TRUE)
end


# Start the tournament
@external
func start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}() -> (success: felt):
    #Ownable_only_owner()
    _only_tournament_registration_closed()
    
    _rec_start()
    
    return (TRUE)
end

# Register a ship for the caller address
# @param ship_address: the address of the ship smart contract
@external
func register{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    ship_address: felt
) -> (success: felt):
    alloc_locals
    _only_tournament_registration_open()
    let (player_address) = get_caller_address()
    let (boarding_pass_token_address) = boarding_pass_token_address_.read()
    # Check access control with NFT boarding pass
    let (player_boarding_pass_balance) = IERC721.balanceOf(
        contract_address=boarding_pass_token_address,
        owner=player_address
    )
    let one = Uint256(1, 0)
    let (is_allowed) = uint256_le(one, player_boarding_pass_balance)
    with_attr error_message("Tournament: player is not allowed to register"):
        assert is_allowed = TRUE
    end   
    let (current_player_count) = player_count_.read()
    let (max_ships_per_tournament) = max_ships_per_tournament_.read()
    # Check that we did not reach the max number of players
    with_attr error_message("Tournament: max player count reached"):
        assert_lt(current_player_count, max_ships_per_tournament)
    end
    let (player_registerd_ship) = player_ship_.read(player_address)
    # Check if player already registered a ship for this tournament
    with_attr error_message("Tournament: player already registered"):
        assert player_registerd_ship = 0
    end
    let (ship_registered_player) = ship_player_.read(ship_address)
    # Check if ship has not been registered by another player
    with_attr error_message("Tournament: ship already registered"):
        assert ship_registered_player = 0
    end
    player_count_.write(current_player_count + 1)
    # Write player => ship association
    player_ship_.write(player_address, ship_address)
    # Write ship => player association
    ship_player_.write(ship_address, player_address)
    # Push ship to array of playing ships
    playing_ships_.write(current_player_count, ship_address)
    playing_ships_count_.write(current_player_count + 1)
    return (TRUE)
end


# -----
# INTERNAL FUNCTIONS
# -----

func _increase_score{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    player_address: felt, points: felt
):
    let (current_score) = player_score_.read(player_address)
    tempvar new_score
    assert new_score = current_score + points
    player_score_.write(player_address, new_score)
    return ()
end

func _decrease_score{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
    player_address: felt, points: felt
):
    let (current_score) = player_score_.read(player_address)
    tempvar new_score
    assert new_score = current_score - points
    player_score_.write(player_address, new_score)
    return ()
end

func _only_tournament_registration_open{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
):
    let (is_tournament_registration_open) = is_tournament_registration_open_.read()
    with_attr error_message("Tournament: tournament is open"):
        assert is_tournament_registration_open = TRUE
    end
    return ()
end

func _only_tournament_registration_closed{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
):
    let (is_tournament_registration_open) = is_tournament_registration_open_.read()
    with_attr error_message("Tournament: tournament is closed"):
        assert is_tournament_registration_open = FALSE
    end
    return ()
end

# Recursively plays all battles until there is only one winner
func _rec_start{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (ship_count) = playing_ships_count_.read()
    assert_not_zero(ship_count)
    
    _rec_play_current_round_battles(0)
    _update_playing_ships()

    let (ship_count) = playing_ships_count_.read()
    if ship_count == 1:
        # This is the end! We have a single winner!
        return ()
    end

    _rec_start()
    return ()
end

# Recursively plays all battles
func _rec_play_current_round_battles{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(battle_ship_index : felt):
    
    let (end_reached : felt, next_battle_ship_index : felt) = _play_next_battle(battle_ship_index)
    if end_reached == TRUE:
        return ()
    end
    
    _rec_play_current_round_battles(next_battle_ship_index)
    return ()
end

# Play the next battle entirely
func _play_next_battle{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(ship_index : felt) -> (end_reached : felt, next_battle_ship_index : felt):
    alloc_locals
    let (ships_len : felt, ships : felt*) = _build_battle_ship_array(ship_index)
    if ships_len == 0:
        return (TRUE, 0)
    end

    let (space_contract) = space_contract_address_.read()
    let (rand_contract) = rand_contract_address_.read()
    let (grid_size) = grid_size_.read()
    let (turn_count) = turn_count_.read()
    let (max_dust) = max_dust_.read()

    ISpace.play_game(space_contract,
            rand_contract, grid_size, turn_count, max_dust,
            ships_len, ships)
    
    let (played_battle_count) = played_battle_count_.read()
    played_battle_count_.write(played_battle_count + 1)

    # TODO: get scores
    # TODO: get winner
    let winner = ships[0]
    let (winner_ships_count) = winner_ships_count_.read()
    winner_ships_.write(winner_ships_count, winner)
    winner_ships_count_.write(winner_ships_count+1)

    return (FALSE, ship_index + ships_len)
end

# Get the ships that will participate in the next battle
func _build_battle_ship_array{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(ship_index : felt) -> (
        ships_len : felt, ships : felt*):
    alloc_locals

    let (local ships : felt*) = alloc()

    let (ships_len) = _rec_build_battle_ship_array(ship_index, 0, ships)

    return (ships_len, ships)
end

func _rec_build_battle_ship_array{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(
        ship_index : felt, ships_len : felt, ships : felt*) -> (len : felt):
    let (ships_per_battle) = ships_per_battle_.read()
    if ships_len == ships_per_battle:
        return (ships_len)
    end

    let (ship_count) = playing_ships_count_.read()
    if ship_index == ship_count:
        return (ships_len)
    end

    let (ship_address : felt) = playing_ships_.read(ship_index)
    assert_not_zero(ship_address)

    assert ships[ships_len] = ship_address

    return _rec_build_battle_ship_array(ship_index + 1, ships_len + 1, ships)
end

func _update_playing_ships{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}():
    let (ship_count) = winner_ships_count_.read()
    playing_ships_count_.write(ship_count)
    winner_ships_count_.write(0)

    _rec_update_playing_ships(0, ship_count)
    return ()
end

func _rec_update_playing_ships{syscall_ptr : felt*, pedersen_ptr : HashBuiltin*, range_check_ptr}(index : felt, count : felt):
    if index == count:
        return ()
    end

    let (ship_address : felt) = winner_ships_.read(index)
    playing_ships_.write(index, ship_address)

    _rec_update_playing_ships(index + 1, count)
    return ()
end

