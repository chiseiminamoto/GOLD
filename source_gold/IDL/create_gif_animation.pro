PRO create_gif_animation,in_filenamelist, outfname, delay_time
  COMPILE_OPT IDL2

  ;Get the number of input files.
  file_nums = N_ELEMENTS(in_filenamelist)

  IF (file_nums GT 0) AND ~STRCMP(in_filenamelist[0], '') THEN BEGIN
    FOR i = 0, file_nums - 1 DO BEGIN
      img = READ_IMAGE(in_filenamelist[i], red, green, blue)

      ;Get the size information.
      img_s = SIZE(img)

      ;If the dimension of the img is 3-D, then convert it to a index image first.
      IF (img_s[0] EQ 3) THEN BEGIN
        img_idx = COLOR_QUAN(img[0, *, *], img[1, *, *], img[2, *, *], tbl_r, tbl_g, tbl_b)

        ;Reverse array in the second dimension.
        img_idx = REFORM(img_idx)

        WRITE_GIF, outfname, img_idx, tbl_r, tbl_g, tbl_b, $
          DELAY_TIME = delay_time, /MULTIPLE, REPEAT_COUNT = 0
      ENDIF

      ;If the dimension of the img is 2-D, then write it to the gif file directly.
      IF (img_s[0] EQ 2) THEN BEGIN
        img = REFORM(img)
        IF (N_ELEMENTS(red) GT 0) AND (N_ELEMENTS(green) GT 0) AND (N_ELEMENTS(blue) GT 0) THEN BEGIN

          WRITE_GIF, outfname, img, red, green, blue, DELAY_TIME = delay_time, /MULTIPLE, REPEAT_COUNT = 0
        ENDIF
      ENDIF
    ENDFOR

    ;Close the file.
    WRITE_GIF, outfname, /CLOSE
  ENDIF
END