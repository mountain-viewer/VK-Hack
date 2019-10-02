import os
import cv2
import pandas as pd
import numpy as np
import imageio
from PIL import Image, ImageFont, ImageDraw
from pygifsicle import optimize
import glob
import json

MATCHES_INFO_PATH = './Data/matches_info.csv'
matches_info_global = pd.read_csv(
    MATCHES_INFO_PATH
)

teams_info_file = './Data/teams_info.json'
with open(teams_info_file, 'r') as file:
    teams_info_global = json.load(file)


def return_closest_match_info(input_dict, matches_df):
    '''
    input_dict = {'lon': 0, 'lat': 0, 'time': 0}
    '''
    lonlat = matches_df.loc[:, ['venue_lon', 'venue_lat']].values
    user_lonlat = np.array([input_dict['lon'], input_dict['lat']])
    dists = np.square(lonlat[:,np.newaxis]-user_lonlat).sum(axis=2)
    closest_venue_id = matches_df.iloc[np.argmin(dists),:]['venue_id']
    closest_matches = matches_df[matches_df['venue_id'] == closest_venue_id]
    closest_match_id = np.argmin(closest_matches['match_start_time'].values - input_dict['time'])
    result = dict(closest_matches.iloc[closest_match_id, :])
    INT_COLS = ['match_id', 'match_start_time', 'venue_capacity', 'home_score', 'away_score']
    FLOAT_COLS = ['venue_lon', 'venue_lat']
    for col in INT_COLS:
        result[col] = int(result[col])
    for col in FLOAT_COLS:
        result[col] = float(result[col])
    del result['Unnamed: 0']
    return result


def alpha_blend(fg, bg, alpha):
    fg = fg.astype("float")
    bg = bg.astype("float")
    alpha = alpha.astype("float") / 255
    fg = cv2.multiply(alpha, fg)
    bg = cv2.multiply(1 - alpha, bg)
    output = cv2.add(fg, bg)
    return output.astype("uint8")


def overlay_image(bg, fg, fgMask, coords):
    (sH, sW) = fg.shape[:2]
    (x, y) = coords
    overlay = np.zeros(bg.shape, dtype="uint8")
    overlay[y:y + sH, x:x + sW] = fg
    alpha = np.zeros(bg.shape[:2], dtype="uint8")
    alpha[y:y + sH, x:x + sW] = fgMask
    alpha = np.dstack([alpha] * 3)
    output = alpha_blend(overlay, bg, alpha)
    return output


def create_sticker_with_info(match_info):
    img = imageio.imread("./Data/versus_bkg.png")
    back_alpha = img[:, :, 3]
    back = img[:, :, :3]
    logo_1 = cv2.resize(
        imageio.imread(match_info["home_team_logo"]), (70, 70)
    )
    logo_2 = cv2.resize(
        imageio.imread(match_info["away_team_logo"]), (70, 70)
    )
    overlay = overlay_image(
        back, logo_1[:, :, :3], logo_1[:, :, 3], (20, 0)
    )
    overlay = overlay_image(
        overlay, logo_2[:, :, :3], logo_2[:, :, 3], (back.shape[1] - 90, 0)
    )
    
    fontpath = "./Data/Grey Sans Bold.ttf"     
    font = ImageFont.truetype(fontpath, 24)
    img_pil = Image.fromarray(overlay)
    draw = ImageDraw.Draw(img_pil)
    b,g,r,a = 0,0,0,0
    draw.text((50, overlay.shape[0] - 35),  str(match_info["home_score"]), font=font, fill=(b,g,r,a))
    draw.text((overlay.shape[1] - 65, overlay.shape[0] - 35),  str(match_info["away_score"]), font=font, fill=(b,g,r,a))
    
    overlay = np.array(img_pil)
    png = np.dstack((overlay, back_alpha))
    return png


def generate_gifs(image, match_info, choice):
    if ((int(choice) == 1) and (match_info["home_score"] > match_info["away_score"])) or ((int(choice) == 2) and (match_info["home_score"] <= match_info["away_score"])):
        GIF_FOLDERS =  ["win"]
    else:
        GIF_FOLDERS =  ["noooo"]
    GIF_FOLDERS += ['goal', '1_0', 'woman_red_card']#, 'noooo', 'win' 'lost']
    SCALE_FACTORS = {'woman_red_card': (2, 2), 'goal': (1, 1), '1_0': (5, 5), 
                     'noooo': (2, 2), 'win': (2, 2)}#, 'lost': (2, 2)}
    COORDS = {'woman_red_card': (0.6, 0.8), 'goal': (0, 0.3), '1_0': (0.1, 0.85), 
              'noooo': (0, 0.8), 'win': (0.1,0.75)}#, 'lost': (0,0.7)}
    NUM_FRAMES = {'woman_red_card': 45, 'goal': 24, '1_0': 10, 
                  'noooo': 8, 'win': 2}#, 'lost': 2}
    DURATION = {'woman_red_card': 50, 'goal': 100, '1_0': 150, 
                'noooo': 100, 'win': 100}#, 'lost': 100}
    
    STATIC_IMAGE = cv2.resize(image, dsize=(480, 640))

    for i, gif_name in enumerate(GIF_FOLDERS):
        static_image = STATIC_IMAGE
        if gif_name == 'win' or gif_name == 'noooo':
            versus_sticker = create_sticker_with_info(match_info=match_info)
            versus_img = versus_sticker[:,:,:3]
            versus_img_mask = versus_sticker[:,:,3]
            static_image = overlay_image(
                bg=static_image, 
                fg=versus_img, 
                fgMask=versus_img_mask, 
                coords=(
                    static_image.shape[1]//4,
                    20
                )
            )
        gif = []
        for img_name in sorted(glob.glob(f'./Data/{gif_name}/frame_*.gif')):
            curr_frame = imageio.mimread(img_name)[0]
            gif.append(
                cv2.resize(
                    curr_frame, 
                    dsize=(
                        curr_frame.shape[1]//SCALE_FACTORS[gif_name][0], 
                        curr_frame.shape[0]//SCALE_FACTORS[gif_name][1])
                )
            ) 
        gif_array = []
        for idx, gif_frame in enumerate(gif):
            gif_img = gif_frame[:,:,:3]
            gif_img_mask = gif_frame[:,:,3]
            overlayed_img = overlay_image(
                bg=static_image, 
                fg=gif_img, 
                fgMask=gif_img_mask, 
                coords=(
                    int(static_image.shape[1]*COORDS[gif_name][0]),
                    int(static_image.shape[1]*COORDS[gif_name][1])
                )
            )
            gif_array.append(Image.fromarray(overlayed_img))
        # GIF version
        gif_array[0].save(
            f'./static/gifs/{i}.gif', 
            save_all=True, 
            append_images=gif_array[:NUM_FRAMES[gif_name]], 
            duration=DURATION[gif_name], 
            loop=0
        )
        optimize(f'./static/gifs/{i}.gif')
        # VIDEO version
#         dump_video(
#             filename=f'./static/gifs/{i}.mp4',
#             clip=gif_array
#         )
        
    return [f'95.213.37.132:5000/static/gifs/{i}.gif' for i in range(len(GIF_FOLDERS))]


def interpolate(f_co, t_co, interval):
        det_co =[(t - f) / interval for f , t in zip(f_co, t_co)]
        for i in range(interval):
            yield [round(f + det * i) for f, det in zip(f_co, det_co)]

            
def return_gradient(teams_info, team_name):
    ALREADY_GENERATED_GRADS = [x.split('.')[0] for x in os.listdir('./static/grads/')]
    if team_name in ALREADY_GENERATED_GRADS:
         return f'http://95.213.37.132:5000/static/grads/{team_name}.jpg'
    h1 = teams_info[team_name]['colors'][0]['first'].lstrip('#')
    h2 = teams_info[team_name]['colors'][0]['second'].lstrip('#')
    rgb1 = tuple(int(h1[i:i+2], 16) for i in (0, 2, 4))
    rgb2 = tuple(int(h2[i:i+2], 16) for i in (0, 2, 4))
    gradient = Image.new('RGBA', (720, 240), color=0)
    draw = ImageDraw.Draw(gradient)
    for i, color in enumerate(interpolate(rgb1, rgb2, 720 * 2)):
        draw.line([(i, 0), (0, i)], tuple(color), width=1)
    gradient = np.array(gradient)
    logo_img = imageio.imread(teams_info[team_name]['logo']['main'])
    scale = gradient.shape[0] / logo_img.shape[1]
    logo_img = cv2.resize(
        logo_img, dsize=(int(logo_img.shape[1]*scale), int(logo_img.shape[0]*scale))
    )
    center_x = gradient.shape[1]//2-logo_img.shape[1]//2
    if logo_img.shape[2] == 3:
        logo_alpha = np.ones((logo_img.shape[0], logo_img.shape[1], 4))*255
        logo_alpha[...,:3] = logo_img
        logo_img = logo_alpha
    grad_with_logo = overlay_image(
        bg=gradient[...,:3], fg=logo_img[...,:3], fgMask=logo_img[...,3], coords=(center_x, 0)
    )
    cv2.imwrite(f'./static/grads/{team_name}.jpg', grad_with_logo)
    return f'http://95.213.37.132:5000/static/grads/{team_name}.jpg'


def return_feed_info(team_name):
    global matches_info_global
    global teams_info_global
    teams_info = teams_info_global
    matches_info = matches_info_global
#     grad_with_logo_link = return_gradient(teams_info, team_name)
    team_id = teams_info[team_name]['id']
    team_matches = matches_info[
        (matches_info['home_team_id'] == team_id) | (matches_info['away_team_id'] == team_id)
    ]
    team_matches = team_matches[
        (team_matches['home_score'] != 0) & (matches_info['away_score'] != 0)
    ]
    team_matches.sort_values('match_start_time', ascending=False, inplace=True)
    matches_for_feed = team_matches.iloc[:2, :]
    result_list = []
    for row_match in matches_for_feed.iterrows():
        score_comment = ''
        match = row_match[1]
        if team_id == match['home_team_id']:
            won = match['home_score'] > match['away_score']
            draw = match['home_score'] == match['away_score']
        elif team_id == match['away_team_id']:
            won = match['away_score'] > match['home_score']
            draw = match['away_score'] == match['home_score']
        score_comment = 'Победа!' if won else ('Ничья!' if draw else 'Проигрыш.')
        score_comment += f' \nФинальный счет: {match["home_score"]} -- {match["away_score"]}'
        score_comment += ' 🎉' if won else (' 😕' if draw else ' 😔')
        show_home_name = match["home_team_name"].split(' ')[0]
        show_away_name = match["away_team_name"].split(' ')[0]
        result_list.append([
            f'{show_home_name} -- {show_away_name}',
            score_comment
        ])
    return result_list
