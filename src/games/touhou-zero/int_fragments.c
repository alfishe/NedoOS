#ifndef INT_FRAGMENTS
#define INT_FRAGMENTS
#include "sprite_pool.c"
#include "engine.c"
#include "interpreter.c"

extern u8 exec_cnt;

i16 yy;
i16 xx;

void int_enemies_pair(u8 type, u16 tile, u16 hp)
{
    switch (exec_cnt)
    {
        case 0: 
            push_npc(32, -32, 0, 2, tile, type, hp, 0); 
            push_npc(266, -32, 0, 2, tile, type, hp, 0); 
            break; 
        case 10: 
            npc_by_type_set_speed(type, 0, 0); 
            break; 
        case  11: 
            npc_type_star(type); 
            break; 
        case 15: 
            npc_by_type_set_speed(type, 0, 5); 
            break; 
    }
}

void int_make_left_flyers(u8 type, i16 y, u16 tile, u16 hp, u16 bonus)
{
    switch (exec_cnt)
    {
        case 0:                                  
        case 3:                              
        case 6:                              
            push_npc(320, y, -3, 0, tile, 30, hp, bonus); 
            break;
    }
}

void int_make_right_flyers(u8 type, i16 y, u16 tile, u16 hp, u16 bonus)
{
    switch (exec_cnt)
    {
        case 0:                                  
        case 3:                              
        case 6:                              
            push_npc(0, y, 3, 0, tile, 30, hp, bonus); 
            break;
    }
}

void int_make_boom_fairy(i16 x, u16 hp, u16 bonus) 
{
    switch (exec_cnt) {
        case 0:                                    
            push_npc(x, -32, 0, 5, FIARY3, 100, hp, bonus); 
            break;                                          
        case 3:                                
            npc_by_type_set_speed(100, 0, 0);               
            break;                                          
        case 5:                                
            npc_type_star(100);                             
            break;                                          
        case 7:                                
            npc_type_star(100);                             
            break;                                          
        case 11:                               
            npc_by_type_set_speed(100, 2, 2);               
            break;
    }
}

void int_make_caravan(u8 type, i16 x, i16 tile, i16 hp, i16 bonus) 
{
    switch (exec_cnt)
    {
        case 0:                                            
            push_npc(x, -32, 0, 2, tile, type, hp, bonus);          
            push_npc(x + 32, -32, 0, 2, tile, type, hp, bonus);     
            break;                                                  
        case 5:                                        
            push_npc(x, -32, 0, 2, tile, type + 1, hp, bonus);      
            push_npc(x + 32, -32, 0, 2, tile, type + 1, hp, bonus); 
            break;                                                  
        case 10:                                       
            push_npc(x, -32, 0, 2, tile, type + 2, hp, bonus);      
            push_npc(x + 32, -32, 0, 2, tile, type + 2, hp, bonus); 
            break;                                                  
        case 15:                                       
            npc_by_type_set_speed(type, (x > 160) ? -4 : 4, 0);     
            break;                                                  
        case 20:                                       
            npc_by_type_set_speed(type + 1, (x > 160) ? -4 : 4, 0); 
            break;                                                  
        case 25:                                       
            npc_type_shoot(type, 3, 3);                             
            npc_type_shoot(type + 1, 4, 3);                         
            npc_type_shoot(type + 2, 5, 3);                         
            npc_by_type_set_speed(type + 2, (x > 160) ? -4 : 4, 0); 
            break;                                                  
        case 27:                                       
            npc_type_shoot(type, 2, 3);                             
            npc_type_shoot(type + 1, 1, 3);                         
            npc_type_shoot(type + 2, 0, 3);                         
            break;                                                  
        case  29:                                       
            npc_type_shoot(type, 1, 3);                             
            npc_type_shoot(type + 1, 0, 3);                         
            npc_type_shoot(type + 2, -1, 3);                        
            break;                                                  
        case 35:                                       
            npc_by_type_set_speed(type, 1, 3);                      
            npc_by_type_set_speed(type + 1, 0, 3);                  
            npc_by_type_set_speed(type + 2, -2, 3);                 
            break;
    }
}

void int_enemy_wave(u16 tile, u8 type, u16 hp) 
{
    switch (exec_cnt) {
        case 0:                                     
            push_npc(144, -32, 2, 2, tile, type, hp, 0);     
            push_npc(176, -32, 2, 2, tile, type, hp, 0);     
            break;                                           
        case 0 + 5:                                 
            push_npc(144, -32, 2, 2, tile, type + 1, hp, 0); 
            push_npc(176, -32, 2, 2, tile, type + 1, hp, 0); 
            npc_by_type_set_speed(type, 0, 2);               
            break;                                           
        case 0 + 10:                                
            push_npc(144, -32, 2, 2, tile, type + 2, hp, 0); 
            push_npc(176, -32, 2, 2, tile, type + 2, hp, 0); 
            npc_by_type_set_speed(type, -2, 2);              
            npc_by_type_set_speed(type + 1, 0, 2);           
            break;                                           
        case 0 + 15:                                
            push_npc(144, -32, 2, 2, tile, type, hp, 0);     
            push_npc(176, -32, 2, 2, tile, type, hp, 0);     
            npc_type_shoot(type, 3, 0);                      
            npc_type_shoot(type, -3, 0);                     
            npc_type_shoot(type + 1, 3, 0);                  
            npc_type_shoot(type + 1, -3, 0);                 
            npc_type_shoot(type + 2, 3, 0);                  
            npc_type_shoot(type + 2, -3, 0);                 
            npc_by_type_set_speed(type, 0, 2);               
            npc_by_type_set_speed(type + 1, -2, 2);          
            npc_by_type_set_speed(type + 2, 0, 2);           
            break;                                           
        case 0 + 20:                                
            npc_by_type_set_speed(type, 2, 2);               
            npc_by_type_set_speed(type + 1, 0, 2);           
            npc_by_type_set_speed(type + 2, -2, 2);          
            npc_type_shoot(type, 3, 3);                      
            npc_type_shoot(type, -3, 3);                     
            npc_type_shoot(type + 1, 3, 0);                  
            npc_type_shoot(type + 1, -3, 0);                 
            npc_type_shoot(type + 2, 3, -3);                 
            npc_type_shoot(type + 2, -3, -3);                
            break;                                           
        case 0 + 25:                                
            npc_by_type_set_speed(type, 0, 2);               
            npc_by_type_set_speed(type + 1, 2, 2);           
            npc_by_type_set_speed(type + 2, 0, 2);           
            npc_type_shoot(type, 3, 3);                      
            npc_type_shoot(type, -3, 3);                     
            npc_type_shoot(type + 1, 3, 0);                  
            npc_type_shoot(type + 1, -3, 0);                 
            npc_type_shoot(type + 2, 3, -3);                 
            npc_type_shoot(type + 2, -3, -3);                
            break;                                           
        case 0 + 30:                                
            npc_by_type_set_speed(type, -2, 2);              
            npc_by_type_set_speed(type + 1, 0, 2);           
            npc_by_type_set_speed(type + 2, 2, 2);           
            npc_type_shoot(type, 3, -3);                     
            npc_type_shoot(type, -3, -3);                    
            npc_type_shoot(type + 1, 3, -3);                 
            npc_type_shoot(type + 1, -3, -3);                
            npc_type_shoot(type + 2, 3, -3);                 
            npc_type_shoot(type + 2, -3, -3);                
            break;                                           
        case 0 + 35:                                
            npc_by_type_set_speed(type, 0, 2);               
            npc_by_type_set_speed(type + 1, 0, 2);           
            npc_by_type_set_speed(type + 2, 0, 2);           
            break;
    }
}

void int_mid_boss1(u16 tile, u16 hp) {
    switch(exec_cnt) {
    case 0: 
        scroll_speed = 0;
        push_npc(160, -32, 0, 5, tile, 200, hp, 0); 
        break; 
    case 0 + 3: 
        npc_by_type_set_speed(200, 2, 0); 
        scroll_speed = 0; 
        break; 
    case 5:
        push_star(find_npc_by_type(200)->sprite.x + 16, find_npc_by_type(200)->sprite.y + 16); 
        break;
    case 0 + 6: 
        if (find_npc_by_type(200) == 0) exec_cnt = 0 + 24; 
        break; 
    case 7:
        push_star(find_npc_by_type(200)->sprite.x + 16, find_npc_by_type(200)->sprite.y + 16); 
        break;
    case 0 + 8: 
        if (find_npc_by_type(200) == 0) exec_cnt = 0 + 24; 
        break; 
    case 9:
        push_star(find_npc_by_type(200)->sprite.x + 16, find_npc_by_type(200)->sprite.y + 16); 
        break; 
    case 0 + 10: 
        if (find_npc_by_type(200) == 0) exec_cnt = 0 + 24; 
        break; 
    case 11:
        push_star(find_npc_by_type(200)->sprite.x + 16, find_npc_by_type(200)->sprite.y + 16); 
        break;
    case 0 + 12: 
        if (find_npc_by_type(200) == 0) exec_cnt = 0 + 24; 
        break; 
    case 0 + 13: 
        npc_by_type_set_speed(200, -2, 0); 
        break; 
    case 15:
        push_star(find_npc_by_type(200)->sprite.x + 16, find_npc_by_type(200)->sprite.y + 16); 
        break;
    case 0 + 16: 
        if (find_npc_by_type(200) == 0) exec_cnt = 0 + 24; 
        break; 
    case 19:
        push_star(find_npc_by_type(200)->sprite.x + 16, find_npc_by_type(200)->sprite.y + 16); 
        break;
    case 0 + 20: 
        if (find_npc_by_type(200) == 0) exec_cnt = 0 + 24; 
        break; 
    case 21:
        push_star(find_npc_by_type(200)->sprite.x + 16, find_npc_by_type(200)->sprite.y + 16); 
        break; 
    case 0 + 22: 
        if (find_npc_by_type(200) == 0) exec_cnt = 0 + 24; 
        break; 
    case 23:
        push_star(find_npc_by_type(200)->sprite.x + 16, find_npc_by_type(200)->sprite.y + 16); 
        break;
    case 0 + 24: 
        if (find_npc_by_type(200)) exec_cnt = 0 + 2; 
        break; 
    case 0 + 25: 
        scroll_speed = 1; 
        for (push_counter = 0;push_counter < 5;push_counter ++) 
            push_bonus((push_counter % 2) == 1 ? BONUS_CARD : HEALTH_CARD, 160, 70, 3 - (push_counter * 2), 3); 
        break;
    }
}

void int_double_caravan(u16 tile, u16 type, u16 hp, u16 bonus)
{
    switch(exec_cnt) 
    {
        case 0:                                           
            push_npc(32, -32, 0, 2, tile, type, hp, bonus);        
            push_npc(270, -32, 0, 2, tile, type + 10, hp, bonus);  
            break;                                                 
        case 0 + 4:                                       
            push_npc(32, -32, 0, 2, tile, type + 1, hp, bonus);    
            push_npc(270, -32, 0, 2, tile, type + 11, hp, bonus);  
            break;                                                 
        case 0 + 8:                                       
            push_npc(32, -32, 0, 2, tile, type + 2, hp, bonus);    
            push_npc(270, -32, 0, 2, tile, type + 12, hp, bonus);  
            break;                                                 
        case 0 + 9:                                       
            npc_by_type_set_speed(type, 2, 0);                     
            npc_by_type_set_speed(type + 10, -2, 0);               
            break;                                                 
        case 0 + 14:                                      
            npc_by_type_set_speed(type + 1, 2, 0);                 
            npc_by_type_set_speed(type + 11, -2, 0);               
            break;                                                 
        case 0 + 19:                                      
            npc_by_type_set_speed(type + 2, 2, 0);                 
            npc_by_type_set_speed(type + 12, -2, 0);               
            break;                                                 
        case 0 + 20:                                      
            npc_aimed_shoot(type);                            
            npc_aimed_shoot(type + 1);                        
            npc_aimed_shoot(type + 2);                        
            npc_aimed_shoot(type + 10);                      
            npc_aimed_shoot(type + 11);                      
            npc_aimed_shoot(type + 12);                      
            break;                                                 
        case 0 + 21:                                      
            npc_by_type_set_speed(type + 10, 0, 2);                
            npc_by_type_set_speed(type + 11, 0, 2);                
            npc_by_type_set_speed(type + 12, 0, 2);                
            npc_by_type_set_speed(type, 0, 2);                     
            npc_by_type_set_speed(type + 1, 0, 2);                 
            npc_by_type_set_speed(type + 2, 0, 2);                 
            break;
    }
}

void int_make_shooting_star(u8 type,u16 x, u16 y, u16 tile, u16 hp)
{
    switch(exec_cnt) 
    {
        case 0:                                          
            push_npc(x - 52, y, 0, 0, tile, type, hp, BONUS_CARD);  
            break;                                                
        case 0 + 1:                                      
            push_npc(x - 51, y - 37, 0, 0, tile, type, hp, BONUS_CARD);  
            break;                                                
        case 0 + 2:                                      
            push_npc(x - 19, y - 60, 0, 0, tile, type, hp, BONUS_CARD);  
            break;                                                
        case 0 + 3:                                      
            push_npc(x + 20, y - 60, 0, 0, tile, type, hp, BONUS_CARD);  
            break;                                                
        case 0 + 4:                                      
            push_npc(x + 52, y - 37, 0, 0, tile, type, hp, BONUS_CARD);  
            break;                                                
        case 0 + 5:                                      
            push_npc(x + 64, y, 0, 0, tile, type, hp, BONUS_CARD); 
            break;                                                
        case 0 + 7:                                      
            push_npc(x + 52, y + 38, 0, 0, tile, type, hp, BONUS_CARD); 
            break;                                                
        case 0 + 8:                                      
            push_npc(x + 20, y + 61, 0, 0, tile, type, hp, BONUS_CARD); 
            break;                                                
        case 0 + 9:                                      
            push_npc(x - 19, y + 61, 0, 0, tile, type, hp, BONUS_CARD); 
            break;                                                
        case 0 + 10:                                     
            push_npc(x - 51, y + 30, 0, 0, tile, type, hp, BONUS_CARD); 
            break;                                                
        case 0 + 15:                                     
        case 0 + 20:                                     
        case 0 + 25:                                     
            push_star(x + 10, y + 10);                                  
            break;                                                
        case 0 + 30:                                     
            npc_by_type_set_speed(type, 0, 5);                    
            break;
    }
}

void int_push_npc(u8 type, i16 x, i16 y, i16 dx, i16 dy, u16 tile, u16 bonus, u16 hp) 
{
    push_npc(x, y, dx, dy, tile, type, hp, bonus);
}

void int_triangle(u8 hp, u16 tile, u16 bonus) 
{
    switch (exec_cnt) 
    {
        case 0: 
            push_npc(160, -10, 0, 2, tile, 10, hp, bonus); 
            break; 
        case 0 + 2: 
            push_npc(128, -10, 0, 2, tile, 11, hp, bonus); 
            push_npc(192, -10, 0, 2, tile, 11, hp, bonus); 
            break; 
        case 0 + 4: 
            push_npc(96, -10, 0, 2, tile, 12, hp, bonus); 
            push_npc(224, -10, 0, 2, tile, 12, hp, bonus); 
            break; 
        case 0 + 8: 
            push_npc(64, -10, 0, 2, tile, 13, hp, bonus); 
            push_npc(256, -10, 0, 2, tile, 13, hp, bonus); 
            break; 
        case 0 + 12: 
            push_npc(32, -10, 0, 2, tile, 14, hp, bonus); 
            push_npc(288, -10, 0, 2, tile, 14, hp, bonus); 
            break; 
        case 0 + 14: 
            npc_by_type_set_speed(10, 0, 0); 
            npc_by_type_set_speed(11, 0, 0); 
            npc_by_type_set_speed(12, 0, 0); 
            npc_by_type_set_speed(13, 0, 0); 
            npc_by_type_set_speed(14, 0, 0); 
            npc_type_shoot(12, 0, 4); 
            npc_type_shoot(13, 0, 4); 
            npc_type_shoot(11, 0, 4); 
            npc_type_shoot(10, 0, 4); 
            break; 
        case 0 + 15: 
        case 0 + 16: 
        case 0 + 17: 
        case 0 + 18: 
            npc_type_shoot(12, 0, 4); 
            npc_type_shoot(13, 0, 4); 
            npc_type_shoot(14, 0, 4); 
            npc_type_shoot(11, 0, 4); 
            npc_type_shoot(10, 0, 4); 
            break; 
        case 0 + 25: 
            npc_by_type_set_speed(10, 0, 2); 
            npc_by_type_set_speed(11, 0, 2); 
            npc_by_type_set_speed(12, 0, 2); 
            npc_by_type_set_speed(13, 0, 2); 
            npc_by_type_set_speed(14, 0, 2); 
            break;
    }
}

void int_make_corridor(u8 type, u16 tile, u16 hp, u16 bonus)
{
    switch(exec_cnt)
    {
        case 0:                                         
        case 0 + 3:                                     
        case 0 + 6:                                     
        case 0 + 9:                                     
            push_npc(10, -32, 0, 3, tile, type, hp, bonus);      
            push_npc(290, -32, 0, 3, tile, type + 1, hp, bonus); 
            break;                                               
        case 0 + 16:                                    
            npc_by_type_set_speed(type, 0, 0);                   
            npc_by_type_set_speed(type + 1, 0, 0);               
            break;                                               
        case 0 + 18:                                    
            npc_aimed_shoot(type);                               
            npc_aimed_shoot(type + 1);                            
            break;                                               
        case 0 + 19:                                    
            npc_by_type_set_speed(type, 0, 3);                   
            npc_by_type_set_speed(type + 1, 0, 3);               
            break;
    }
}

void int_make_triangle_half(u8 isLeft, u16 tile, u8 hp, u16 bonus) 
{
    switch (exec_cnt) 
    {
    case 0: 
        push_npc(160, -10, 0, 2, tile, 10, hp, bonus); 
        break; 
    case 0 + 2: 
        push_npc(isLeft ? 128 : 188, -10, 0, 2, tile, 11, hp, bonus); 
        break; 
    case 0 + 4: 
        push_npc(isLeft ? 96 : 220, -10, 0, 2, tile, 12, hp, bonus); 
        break; 
    case 0 + 8: 
        push_npc(isLeft ? 64 : 252, -10, 0, 2, tile, 13, hp, bonus); 
        break; 
    case 0 + 12: 
        push_npc(isLeft ? 32 : 284, -10, 0, 2, tile, 14, hp, bonus); 
        break; 
    case 0 + 14: 
        npc_by_type_set_speed(10, 0, 0); 
        npc_by_type_set_speed(11, 0, 0); 
        npc_by_type_set_speed(12, 0, 0); 
        npc_by_type_set_speed(13, 0, 0); 
        npc_by_type_set_speed(14, 0, 0); 
        npc_aimed_shoot(10); 
        npc_aimed_shoot(11); 
        npc_aimed_shoot(12); 
        npc_aimed_shoot(13); 
        npc_aimed_shoot(14); 
        break; 
    case 0 + 15: 
    case 0 + 16: 
    case 0 + 17: 
    case 0 + 18: 
        npc_aimed_shoot(10); 
        npc_aimed_shoot(11); 
        npc_aimed_shoot(12); 
        npc_aimed_shoot(13); 
        npc_aimed_shoot(14); 
        break; 
    case 0 + 25: 
        npc_by_type_set_speed(10, isLeft ? 2 : -2, 2); 
        npc_by_type_set_speed(11, isLeft ? 2 : -2, 2); 
        npc_by_type_set_speed(12, isLeft ? 2 : -2, 2); 
        npc_by_type_set_speed(13, isLeft ? 2 : -2, 2); 
        npc_by_type_set_speed(14, isLeft ? 2 : -2, 2); 
        break;
    }
}

void int_dropped_enemy(u8 hp, u16 x,u16 tile)
{
    push_npc(x, -10, 0, 4, tile, 1, hp, 0); 
    push_npc(x + 96, -10, 0, 4, tile, 1, hp, 0); 
}

void int_firing_trap(u16 tile)
{
    switch(exec_cnt) {
        case 0: 
            push_npc(32, 32, 0 ,0, tile, 50, 60, BONUS_CARD); 
            push_npc(288, 32, 0 ,0, tile, 50, 60, HEALTH_CARD); 
            push_npc(32, 120, 0 ,0, tile, 50, 60, HEALTH_CARD); 
            push_npc(288, 120, 0 ,0, tile, 50, 60, BONUS_CARD); 
            break; 
        case 5: 
        case 10:
        case 15:
        case 20: 
        case 25:
        case 30: 
        case 35:
        case 40: 
        case 45:
        case 50: 
        case 55:
        case 60: 
        case 65:
        case 70: 
        case 75: 
        case 80: 
            npc_aimed_shoot(50); 
            break; 
        case 0 + 85: 
            npc_by_type_set_speed(50, 0, 3); 
            break;
    }
}

void int_mid_boss2(u16 tile, u16 hp)
{
    switch(exec_cnt) {
        case 0: 
            push_npc(160, 32, 2, 0, tile, 200, hp, HEALTH_CARD); 
            scroll_speed = 0; 
            break; 
        case 0 + 2: 
        case 0 + 4: 
        case 0 + 7: 
        case 0 + 9: 
            npc_aimed_shoot(200); 
            if (find_npc_by_type(200) == 0) exec_cnt = 0 + 24; 
            break; 
        case 10:
            push_star(find_npc_by_type(200)->sprite.x + 16, find_npc_by_type(200)->sprite.y + 16);
            break;
        case 0 + 11: 
            npc_by_type_set_speed(200, -2, 0); 
            if (find_npc_by_type(200) == 0) exec_cnt = 0 + 24; 
            break; 
        case 0 + 12: 
        case 0 + 14: 
        case 0 + 18: 
            npc_aimed_shoot(200); 
            if (find_npc_by_type(200) == 0) exec_cnt = 0 + 24; 
            break; 
        case 22:
            push_star(find_npc_by_type(200)->sprite.x + 16, find_npc_by_type(200)->sprite.y + 16);
            break; 
        case 0 + 23: 
            npc_by_type_set_speed(200, 2, 0); 
            exec_cnt = 0; 
            if (find_npc_by_type(200) == 0) exec_cnt = 0 + 24; 
            break; 
        case 0 + 25: 
            scroll_speed = 1; 
            push_bonus(HEALTH_CARD, 160, 120, 0, -5); 
            push_bonus(BONUS_CARD, 170, 110, 0, -5); 
            push_bonus(HEALTH_CARD, 150, 150, 0, -5); 
            push_bonus(BONUS_CARD, 130, 100, 0, -5); 
            push_bonus(BONUS_CARD, 140, 110, 0, -5); 
            push_bonus(HEALTH_CARD, 150, 140, 0, -5); 
            push_bonus(BONUS_CARD, 130, 120, 0, -5); 
            break;
    }
}

void int_aimed_side_enemies(u8 hp, u16 tile) 
{
   if (exec_cnt % 5 == 0) {
            yy = player.y;
            push_npc(1, yy, 5, 0, tile, 100, hp, BONUS_CARD);
            push_npc(1, yy - 32, 5, 0, tile, 100, hp, BONUS_CARD);
            push_npc(300, yy + 16, -5, 0, tile, 100, hp, BONUS_CARD);
   }
}

void int_aimed_circle(u8 hp, u16 tile) 
{
    u8 type = 10 + (exec_cnt / 10);
    switch (exec_cnt % 10)
    {
        case 0:   
            xx = player.x;
            yy = player.y - 16;                                       
            push_npc(xx - 52, yy, 0, 0, tile, type, hp, BONUS_CARD);                                
            push_npc(xx - 51, yy - 37, 0, 0, tile, type, hp, BONUS_CARD);                                  
            push_npc(xx - 19, yy - 60, 0, 0, tile, type, hp, BONUS_CARD);                                      
            push_npc(xx + 20, yy - 60, 0, 0, tile, type, hp, BONUS_CARD);                                      
            push_npc(xx + 52, yy - 37, 0, 0, tile, type, hp, BONUS_CARD);                                      
            push_npc(xx + 64, yy, 0, 0, tile, type, hp, BONUS_CARD);          
            break;         
        case 9:
            npc_by_type_set_speed(type, 0, 5);
            break;
    }
}

void int_marisa_help()
{
    switch (exec_cnt)
    {
    case 0:
        push_npc(300, 60, -5, 0, MARISA, 200, 1024, HEALTH_CARD);
        break;
    case 7:
        npc_by_type_set_speed(200, 0, 0);
        break;
    case 8:
        xx = find_npc_by_type(200)->sprite.x;
        yy = find_npc_by_type(200)->sprite.y;
        push_bonus(HEALTH_CARD, xx - 16, yy + 16, 0, 3);
        push_bonus(HEALTH_CARD, xx, yy + 16, 0, 3);
        push_bonus(HEALTH_CARD, xx + 16, yy + 16, 0, 3);
        break;
    case 9:
        npc_by_type_set_speed(200, 0, -5);
        break;
    default:
        break;
    }
}

void int_set_speed(u8 type, i16 dx, i16 dy) 
{
    npc_by_type_set_speed(type, dx, dy);
}

void int_aimed_shoot(u8 type) 
{
    npc_aimed_shoot(type);
}
#endif