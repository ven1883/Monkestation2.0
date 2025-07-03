import { useBackend, useLocalState } from '../backend';
import { capitalizeAll } from 'common/string';
import { BooleanLike, classes } from 'common/react';
import { Window } from '../layouts';
import { Section, Tabs, Button, LabeledList, Stack, Box } from '../components';
import { ColorItem } from './RapidPipeDispenser';
import { SiloItem, MatterItem } from './RapidConstructionDevice';

type Data = {
  silo_upgraded: BooleanLike;
  layer_icon: string;
  categories: Category[];
  selected_category: string;
  selected_recipe: string;
  piping_layer: number;
};

type Category = {
  cat_name: string;
  recipes: Recipe[];
  active: BooleanLike;
};

type Recipe = {
  index: number;
  icon: string;
  selected: BooleanLike;
  name: string;
};

const PlumbingTypeSection = (props) => {
  const { act, data } = useBackend<Data>();
  const { categories = [], selected_category, selected_recipe } = data;
  const [categoryName, setCategoryName] = useLocalState(
    'categoryName',
    selected_category,
  );
  const shownCategory =
    categories.find((category) => category.cat_name === categoryName) ||
    categories[0];
  return (
    <Section fill scrollable>
      <Tabs>
        {categories.map((category) => (
          <Tabs.Tab
            fluid
            key={category.cat_name}
            selected={category.cat_name === shownCategory.cat_name}
            onClick={() => setCategoryName(category.cat_name)}
          >
            {category.cat_name}
          </Tabs.Tab>
        ))}
      </Tabs>
      {shownCategory?.recipes.map((recipe) => (
        <Button
          key={recipe.index}
          fluid
          ellipsis
          color="transparent"
          selected={recipe.name === selected_recipe}
          onClick={() =>
            act('recipe', {
              id: recipe.index,
            })
          }
        >
          <Box
            inline
            verticalAlign="middle"
            mr="20px"
            className={classes(['plumbing-tgui32x32', recipe.icon])}
            style={{
              transform: 'scale(1.5) translate(9.5%, 9.5%)',
              '-ms-interpolation-mode': 'nearest-neighbor',
              'image-rendering': 'pixelated',
            }}
          />
          <span>{capitalizeAll(recipe.name)}</span>
        </Button>
      ))}
    </Section>
  );
};

// MONKESTATION ADDITION -- added context to layer select and useBackend<Data>()
export const LayerSelect = (props) => {
  const { act, data } = useBackend<Data>();
  const { piping_layer } = data;
  return (
    <LabeledList.Item label="Layer">
      {[1, 2, 3, 4, 5].map((layer) => (
        <Button.Checkbox
          key={layer}
          checked={layer === piping_layer}
          content={layer}
          onClick={() =>
            act('piping_layer', {
              piping_layer: layer,
            })
          }
        />
      ))}
    </LabeledList.Item>
  );
};

const LayerIconSection = (props) => {
  const { data } = useBackend<Data>();
  const { layer_icon } = data;
  return (
    <Box
      m={1}
      className={classes(['plumbing-tgui32x32', layer_icon])}
      style={{
        transform: 'scale(2)',
        '-ms-interpolation-mode': 'nearest-neighbor',
        'image-rendering': 'pixelated',
      }}
    />
  );
};

export const RapidPlumbingDevice = (props) => {
  const { data } = useBackend<Data>();
  const { silo_upgraded } = data;
  return (
    <Window width={480} height={575}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section>
              <Stack>
                <Stack.Item>
                  <ColorItem />
                  <LayerSelect />
                  <MatterItem />
                  {!!silo_upgraded && <SiloItem />}
                </Stack.Item>
                <Stack.Item>
                  <LayerIconSection />
                </Stack.Item>
              </Stack>
            </Section>
          </Stack.Item>
          <Stack.Item grow>
            <PlumbingTypeSection />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
