#ifndef INTERPRETER_C
#define INTERPRETER_C

#include <evo.h>
#include "bytecode.h"
#include "int_fragments.c"

struct vm_cmd {
    u8 id;
    u8 count;
    u8 length;
    u8 p0;
    i16 p1;
    i16 p2;
    i16 p3;
    i16 p4;
    i16 p5;
    i16 p6;
    i16 p7;
};

typedef struct vm_cmd VMCmd; 

u8 *code;

u16 pc = 0 ;
u8 exec_cnt = 0;
u8 executing = 0;

static void init_vm(u8 *level)
{
    pc = 0;
    exec_cnt = 0;
    code = level;
    executing = 1;
}

static void vm_step()
{
    VMCmd* curCmd;

    if (!executing)
        return;
    
    curCmd = (void*) (code + pc);
    
    if (exec_cnt >= curCmd->count) {
        exec_cnt = 0;
        pc += curCmd->length;
        curCmd = (void*) (code + pc);
    }

    switch (curCmd->id)
    {
        case NOP_CMD:
            break;
        case JUST_STAR_CMD:
            push_star(curCmd->p1, curCmd->p2); 
            break;
        case ENEMIES_PAIR_CMD:
            int_enemies_pair(curCmd->p0, curCmd->p1, curCmd->p2);
            break;
        case MAKE_CARAVAN_CMD:
            int_make_caravan(curCmd->p0, curCmd->p1, curCmd->p2, curCmd->p3, curCmd->p4);
            break;
        case MAKE_LEFT_FLYERS_CMD:
            int_make_left_flyers(curCmd->p0, curCmd->p1, curCmd->p2, curCmd->p3, curCmd->p4);
            break;
        case MAKE_RIGHT_FLYERS_CMD:
            int_make_right_flyers(curCmd->p0, curCmd->p1, curCmd->p2, curCmd->p3, curCmd->p4);
            break;
        case MAKE_BOOM_FAIRY_CMD:
            int_make_boom_fairy(curCmd->p1, curCmd->p0, curCmd->p2);
            break;
        case ENEMY_WAVE_CMD:
            int_enemy_wave(curCmd->p1, curCmd->p0, curCmd->p2);
            break;
        case MID_BOSS1_CMD:
            int_mid_boss1(curCmd->p1, curCmd->p2);
            break;
        case DOUBLE_CARAVAN_CMD:
            int_double_caravan(curCmd->p1, curCmd->p0, curCmd->p2, curCmd->p3);
            break;
        case MAKE_SHOOTING_STAR_CMD:
            int_make_shooting_star(curCmd->p0, curCmd->p1, curCmd->p2, curCmd->p3, curCmd->p4);
            break;
        case PUSH_NPC_CMD:
            int_push_npc(curCmd->p0, curCmd->p1, curCmd->p2, curCmd->p3, curCmd->p4, curCmd->p5, curCmd->p6, curCmd->p7);
            break;
        case TRIANGLE_CMD:
            int_triangle(curCmd->p0, curCmd->p1, curCmd->p2);
            break;
        case MAKE_CORRIDOR_CMD:
            int_make_corridor(curCmd->p0, curCmd->p1, curCmd->p2, curCmd->p3);
            break;
        case TRIANGLE_HALF_CMD:
            int_make_triangle_half(curCmd->p0, curCmd->p1, curCmd->p2, curCmd->p3);
            break;
        case DROPPED_ENEMY_CMD:
            int_dropped_enemy(curCmd->p0, curCmd->p1, curCmd->p2);
            break;
        case FIRING_TRAP_CMD:
            int_firing_trap(curCmd->p1);
            break;
        case MID_BOSS2_CMD:
            int_mid_boss2(curCmd->p1, curCmd->p2);
            break;
        case AIMED_SIDE_ENEMIES_CMD:
            int_aimed_side_enemies(curCmd->p0, curCmd->p1);
            break;
        case AIMED_CIRCLE_CMD:
            int_aimed_circle(curCmd->p0, curCmd->p1);
            break;
        case MARISA_HELP_CMD:
            int_marisa_help();
            break;
        case SET_SPEED_CMD:
            int_set_speed(curCmd->p0, curCmd->p1, curCmd->p2);
            break;
        case AIMED_SHOT_CMD:
            int_aimed_shoot(curCmd->p0);
            break;
        case END_CMD:
            executing = 0;
            break;
        
        default:
                __asm
                    di
                    halt
                __endasm;
            break;
    }

    exec_cnt ++ ;
}

#endif