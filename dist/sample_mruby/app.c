/**
 ******************************************************************************
 ** ファイル名 : app.c
 **
 ** 概要 : 二輪差動型ライントレースロボットのTOPPERS/HRP3用mrubyサンプルプログラム
 **
 ******************************************************************************
 **/

#include "ev3api.h"
#include "app.h"
// #include "etroboc_ext.h"  //TODO 移植必要かも

#if defined(BUILD_MODULE)
    #include "module_cfg.h"
#else
    #include "kernel_cfg.h"
#endif

#include "mruby.h"
#include "mruby/irep.h"
#include "mruby/string.h"

#define DEBUG

#if defined(DEBUG)
    #define _debug(x) (x)
#else
    #define _debug(x)
#endif

/* メインタスク */
void main_task(intptr_t unused)
{
    syslog(LOG_NOTICE, "HackEV sample_mruby");

	static mrb_state *mrb = NULL;
	mrb_value ret;
	mrb = mrb_open();
	struct RClass * ev3rt = mrb_class_get(mrb, "EV3RT");
    mrb_define_const(mrb, ev3rt, "MAIN_TASK", mrb_fixnum_value(MAIN_TASK));
	mrb_define_const(mrb, ev3rt, "TRACER_TASK", mrb_fixnum_value(TRACER_TASK));
	mrb_define_const(mrb, ev3rt, "CYC_TRACER", mrb_fixnum_value(CYC_TRACER));

    #include "main_task.h"

    ret = mrb_load_irep (mrb, bcode);
    if(mrb->exc){
        syslog(LOG_NOTICE, "#### load_irep done");
        if(!mrb_undef_p(ret)){
            syslog(LOG_NOTICE, "#### EV3way-ET ERR");
		    mrb_value s = mrb_funcall(mrb, mrb_obj_value(mrb->exc), "inspect", 0);
		    if (mrb_string_p(s)) {
                char *p = RSTRING_PTR(s);
                syslog(LOG_NOTICE, "#### mruby err msg:%s", p);
		    } else {
            syslog(LOG_NOTICE, "#### error unknown!");
		    }
		}else{
            syslog(LOG_NOTICE, "#### mrb_undef_p(ret)");
        }
     }else{
         // 正常終了
        syslog(LOG_NOTICE, "#### mruby exit OK");
     }
    mrb_close(mrb);

    ext_tsk();
}

/* トレーサータスク */
void tracer_task(intptr_t unused)
{
    /* LCD画面表示 */
    ev3_lcd_fill_rect(0, 0, EV3_LCD_WIDTH, EV3_LCD_HEIGHT, EV3_LCD_WHITE);

	static mrb_state *mrb = NULL;
	mrb_value ret;
	mrb = mrb_open();
	struct RClass * ev3rt = mrb_class_get(mrb, "EV3RT");
    mrb_define_const(mrb, ev3rt, "MAIN_TASK", mrb_fixnum_value(MAIN_TASK));
	mrb_define_const(mrb, ev3rt, "TRACER_TASK", mrb_fixnum_value(TRACER_TASK));
	mrb_define_const(mrb, ev3rt, "CYC_TRACER", mrb_fixnum_value(CYC_TRACER));

    #include "tracer_task.h"

    ret = mrb_load_irep (mrb, bcode);
    if(mrb->exc){
        syslog(LOG_NOTICE, "#### load_irep done (t)");
        if(!mrb_undef_p(ret)){
            syslog(LOG_NOTICE, "#### EV3way-ET ERR (t)");
		    mrb_value s = mrb_funcall(mrb, mrb_obj_value(mrb->exc), "inspect", 0);
		    if (mrb_string_p(s)) {
                char *p = RSTRING_PTR(s);
                syslog(LOG_NOTICE, "#### mruby err msg(t):%s", p);
		    } else {
            syslog(LOG_NOTICE, "#### error unknown! (t)");
		    }
		}else{
            syslog(LOG_NOTICE, "#### mrb_undef_p(ret) (t)");
        }
     }else{
         // 正常終了
        syslog(LOG_NOTICE, "#### mruby exit OK (t)");
     }
    mrb_close(mrb);

    ext_tsk();
}
