function Prateleira1()
---FUNCTION LEFT OR RIGHT
   promocaoPanel:getChildById("LeftButton"):hide()
   -- promocaoPanw):getChildById("RightButton"):hide()
   promocaoPanel:getChildById("RightButton"):show()
   promocaoPanel:getChildById("RightButton").onClick = function() Prateleira2() end
---FUNCTION LEFT OR RIGHT

-- PRIMEIRO ITEM DA PRATELEIRA
   local Window = "WindowPratileira1"
   local Name = "misty"
   local Diamond = 8
   local PokeCoin = 16
   
   local Sex1 = "female" --Primeiro Icone de Sexo
   local Sex1Texto = "Feminino"
   -- local Sex1_Texto = "Masculino"
   
   local Sex2 = "male" --Segundo Icone de Sexo
   -- local Sex2_Texto = "Feminino"
   local Sex2Texto = "Masculino"

   promocaoPanel:getChildById(Window):getChildById("Comprar"):setImageSource('images/promocao/buttons/comprar_pratileira')
   promocaoPanel:getChildById(Window):getChildById("Comprar").onClick = function() MistyOutfit() end

   promocaoPanel:getChildById(Window):show()
   promocaoPanel:getChildById(Window):setImageSource('images/promocao/pratileira/background/'..Name)
   promocaoPanel:getChildById(Window):getChildById("SlotItemPratileira"):setImageSource('images/promocao/pratileira/item/'..Name)
   
   -- promocaoPanel:getChildById(Window):getChildById("Star"):show()
   promocaoPanel:getChildById(Window):getChildById("Star").tooltip = "Essa roupa possui a habilidade\nde TAUNT"
   
   promocaoPanel:getChildById(Window):getChildById("Sex1"):show()
   promocaoPanel:getChildById(Window):getChildById("Sex1"):setImageSource('images/promocao/pratileira/'..Sex1)
   promocaoPanel:getChildById(Window):getChildById("Sex1").tooltip = Sex1Texto
   
   -- promocaoPanel:getChildById(Window):getChildById("Sex2"):show()
   promocaoPanel:getChildById(Window):getChildById("Sex2"):setImageSource('images/promocao/pratileira/'..Sex2)
   promocaoPanel:getChildById(Window):getChildById("Sex2").tooltip = Sex2Texto
   
   promocaoPanel:getChildById(Window):getChildById("Diamond"):setImageSource('images/count/diamond/'..Diamond)
   promocaoPanel:getChildById(Window):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..PokeCoin)
   promocaoPanel:getChildById(Window):getChildById("NameItem"):setImageSource('images/promocao/pratileira/name/'..Name)
-- PRIMEIRO ITEM DA PRATELEIRA
-- SEGUNDO ITEM DA PRATELEIRA
   local Window = "WindowPratileira2"
   local Name = "blueExorcist"
   local Diamond = 8
   local PokeCoin = 16
   
   local Sex1 = "male" --Primeiro Icone de Sexo
   -- local Sex1Texto = "Feminino"
   local Sex1_Texto = "Masculino"
   
   local Sex2 = "male" --Segundo Icone de Sexo
   -- local Sex2_Texto = "Feminino"
   local Sex2Texto = "Masculino"

   promocaoPanel:getChildById(Window):getChildById("Comprar"):setImageSource('images/promocao/buttons/comprar_pratileira')
   promocaoPanel:getChildById(Window):getChildById("Comprar").onClick = function() AlertWindow() end
   
   promocaoPanel:getChildById(Window):show()
   promocaoPanel:getChildById(Window):setImageSource('images/promocao/pratileira/background/'..Name)
   promocaoPanel:getChildById(Window):getChildById("SlotItemPratileira"):setImageSource('images/promocao/pratileira/item/'..Name)
   
   -- promocaoPanel:getChildById(Window):getChildById("Star"):show()
   promocaoPanel:getChildById(Window):getChildById("Star").tooltip = "Essa roupa possui a habilidade\nde TAUNT"
   
   promocaoPanel:getChildById(Window):getChildById("Sex1"):show()
   promocaoPanel:getChildById(Window):getChildById("Sex1"):setImageSource('images/promocao/pratileira/'..Sex1)
   promocaoPanel:getChildById(Window):getChildById("Sex1").tooltip = Sex1Texto
   
   -- promocaoPanel:getChildById(Window):getChildById("Sex2"):show()
   promocaoPanel:getChildById(Window):getChildById("Sex2"):setImageSource('images/promocao/pratileira/'..Sex2)
   promocaoPanel:getChildById(Window):getChildById("Sex2").tooltip = Sex2Texto
   
   promocaoPanel:getChildById(Window):getChildById("Diamond"):setImageSource('images/count/diamond/'..Diamond)
   promocaoPanel:getChildById(Window):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..PokeCoin)
   promocaoPanel:getChildById(Window):getChildById("NameItem"):setImageSource('images/promocao/pratileira/name/'..Name)
-- SEGUNDO ITEM DA PRATELEIRA
-- TERCEIRO ITEM DA PRATELEIRA
   local Window = "WindowPratileira3"
   local Name = "arlequina"
   local Diamond = 8
   local PokeCoin = 16
   
   local Sex1 = "female" --Primeiro Icone de Sexo
   local Sex1Texto = "Feminino"
   -- local Sex1_Texto = "Masculino"
   
   local Sex2 = "male" --Segundo Icone de Sexo
   -- local Sex2_Texto = "Feminino"
   local Sex2Texto = "Masculino"

   promocaoPanel:getChildById(Window):getChildById("Comprar"):setImageSource('images/promocao/buttons/comprar_pratileira')
   promocaoPanel:getChildById(Window):getChildById("Comprar").onClick = function() BuzzBox() end
   
   promocaoPanel:getChildById(Window):show()
   promocaoPanel:getChildById(Window):setImageSource('images/promocao/pratileira/background/'..Name)
   promocaoPanel:getChildById(Window):getChildById("SlotItemPratileira"):setImageSource('images/promocao/pratileira/item/'..Name)
   
   -- promocaoPanel:getChildById(Window):getChildById("Star"):show()
   promocaoPanel:getChildById(Window):getChildById("Star").tooltip = "Essa roupa possui a habilidade\nde TAUNT"
   
   promocaoPanel:getChildById(Window):getChildById("Sex1"):show()
   promocaoPanel:getChildById(Window):getChildById("Sex1"):setImageSource('images/promocao/pratileira/'..Sex1)
   promocaoPanel:getChildById(Window):getChildById("Sex1").tooltip = Sex1Texto
   
   -- promocaoPanel:getChildById(Window):getChildById("Sex2"):show()
   promocaoPanel:getChildById(Window):getChildById("Sex2"):setImageSource('images/promocao/pratileira/'..Sex2)
   promocaoPanel:getChildById(Window):getChildById("Sex2").tooltip = Sex2Texto
   
   promocaoPanel:getChildById(Window):getChildById("Diamond"):setImageSource('images/count/diamond/'..Diamond)
   promocaoPanel:getChildById(Window):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..PokeCoin)
   promocaoPanel:getChildById(Window):getChildById("NameItem"):setImageSource('images/promocao/pratileira/name/'..Name)
-- TERCEIRO ITEM DA PRATELEIRA
-- QUARTO ITEM DA PRATELEIRA
   local Window = "WindowPratileira4"
   local Name = "ashketchum"
   local Diamond = 8
   local PokeCoin = 16
   
   local Sex1 = "male" --Primeiro Icone de Sexo
   -- local Sex1Texto = "Feminino"
   local Sex1_Texto = "Masculino"
   
   local Sex2 = "male" --Segundo Icone de Sexo
   -- local Sex2_Texto = "Feminino"
   local Sex2Texto = "Masculino"

   promocaoPanel:getChildById(Window):getChildById("Comprar"):setImageSource('images/promocao/buttons/comprar_pratileira')
   promocaoPanel:getChildById(Window):getChildById("Comprar").onClick = function() BuzzBox() end
   
   promocaoPanel:getChildById(Window):show()
   promocaoPanel:getChildById(Window):setImageSource('images/promocao/pratileira/background/'..Name)
   promocaoPanel:getChildById(Window):getChildById("SlotItemPratileira"):setImageSource('images/promocao/pratileira/item/'..Name)
   
   -- promocaoPanel:getChildById(Window):getChildById("Star"):show()
   promocaoPanel:getChildById(Window):getChildById("Star").tooltip = "Essa roupa possui a habilidade\nde TAUNT"
   
   promocaoPanel:getChildById(Window):getChildById("Sex1"):show()
   promocaoPanel:getChildById(Window):getChildById("Sex1"):setImageSource('images/promocao/pratileira/'..Sex1)
   promocaoPanel:getChildById(Window):getChildById("Sex1").tooltip = Sex1Texto
   
   -- promocaoPanel:getChildById(Window):getChildById("Sex2"):show()
   promocaoPanel:getChildById(Window):getChildById("Sex2"):setImageSource('images/promocao/pratileira/'..Sex2)
   promocaoPanel:getChildById(Window):getChildById("Sex2").tooltip = Sex2Texto
   
   promocaoPanel:getChildById(Window):getChildById("Diamond"):setImageSource('images/count/diamond/'..Diamond)
   promocaoPanel:getChildById(Window):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..PokeCoin)
   promocaoPanel:getChildById(Window):getChildById("NameItem"):setImageSource('images/promocao/pratileira/name/'..Name)
-- QUARTO ITEM DA PRATELEIRA
-- QUINTO ITEM DA PRATELEIRA
   local Window = "WindowPratileira5"
   local Name = "tonystark"
   local Diamond = 8
   local PokeCoin = 16
   
   local Sex1 = "male" --Primeiro Icone de Sexo
   -- local Sex1Texto = "Feminino"
   local Sex1_Texto = "Masculino"
   
   local Sex2 = "male" --Segundo Icone de Sexo
   -- local Sex2_Texto = "Feminino"
   local Sex2Texto = "Masculino"

   promocaoPanel:getChildById(Window):getChildById("Comprar"):setImageSource('images/promocao/buttons/comprar_pratileira')
   promocaoPanel:getChildById(Window):getChildById("Comprar").onClick = function() BuzzBox() end
   
   promocaoPanel:getChildById(Window):show()
   promocaoPanel:getChildById(Window):setImageSource('images/promocao/pratileira/background/'..Name)
   promocaoPanel:getChildById(Window):getChildById("SlotItemPratileira"):setImageSource('images/promocao/pratileira/item/'..Name)
   
   -- promocaoPanel:getChildById(Window):getChildById("Star"):show()
   promocaoPanel:getChildById(Window):getChildById("Star").tooltip = "Essa roupa possui a habilidade\nde TAUNT"
   
   promocaoPanel:getChildById(Window):getChildById("Sex1"):show()
   promocaoPanel:getChildById(Window):getChildById("Sex1"):setImageSource('images/promocao/pratileira/'..Sex1)
   promocaoPanel:getChildById(Window):getChildById("Sex1").tooltip = Sex1Texto
   
   -- promocaoPanel:getChildById(Window):getChildById("Sex2"):show()
   promocaoPanel:getChildById(Window):getChildById("Sex2"):setImageSource('images/promocao/pratileira/'..Sex2)
   promocaoPanel:getChildById(Window):getChildById("Sex2").tooltip = Sex2Texto
   
   promocaoPanel:getChildById(Window):getChildById("Diamond"):setImageSource('images/count/diamond/'..Diamond)
   promocaoPanel:getChildById(Window):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..PokeCoin)
   promocaoPanel:getChildById(Window):getChildById("NameItem"):setImageSource('images/promocao/pratileira/name/'..Name)
-- QUINTO ITEM DA PRATELEIRA
-- SEXTO ITEM DA PRATELEIRA
   local Window = "WindowPratileira6"
   local Name = "hoho"
   local Diamond = 12
   local PokeCoin = 24
   
   local Sex1 = "female" --Primeiro Icone de Sexo
   local Sex1Texto = "Feminino"
   -- local Sex1_Texto = "Masculino"
   
   local Sex2 = "male" --Segundo Icone de Sexo
   -- local Sex2_Texto = "Feminino"
   local Sex2Texto = "Masculino"

   promocaoPanel:getChildById(Window):getChildById("Comprar"):setImageSource('images/promocao/buttons/comprar_pratileira')
   promocaoPanel:getChildById(Window):getChildById("Comprar").onClick = function() BuzzBox() end
   
   promocaoPanel:getChildById(Window):show()
   promocaoPanel:getChildById(Window):setImageSource('images/promocao/pratileira/background/'..Name)
   promocaoPanel:getChildById(Window):getChildById("SlotItemPratileira"):setImageSource('images/promocao/pratileira/item/'..Name)
   
   -- promocaoPanel:getChildById(Window):getChildById("Star"):show()
   promocaoPanel:getChildById(Window):getChildById("Star").tooltip = "Essa roupa possui a habilidade\nde TAUNT"
   
   -- promocaoPanel:getChildById(Window):getChildById("Sex1"):show()
   promocaoPanel:getChildById(Window):getChildById("Sex1"):setImageSource('images/promocao/pratileira/'..Sex1)
   promocaoPanel:getChildById(Window):getChildById("Sex1").tooltip = Sex1Texto
   
   -- promocaoPanel:getChildById(Window):getChildById("Sex2"):show()
   promocaoPanel:getChildById(Window):getChildById("Sex2"):setImageSource('images/promocao/pratileira/'..Sex2)
   promocaoPanel:getChildById(Window):getChildById("Sex2").tooltip = Sex2Texto
   
   promocaoPanel:getChildById(Window):getChildById("Diamond"):setImageSource('images/count/diamond/'..Diamond)
   promocaoPanel:getChildById(Window):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..PokeCoin)
   promocaoPanel:getChildById(Window):getChildById("NameItem"):setImageSource('images/promocao/pratileira/name/'..Name)
-- SEXTO ITEM DA PRATELEIRA
end
function Prateleira2()
---FUNCTION LEFT OR RIGHT
   -- promocaoPanel:getChildById(Window):getChildById("LeftButton"):hide()
   promocaoPanel:getChildById("RightButton"):hide()
   promocaoPanel:getChildById("LeftButton"):show()
   promocaoPanel:getChildById("LeftButton").onClick = function() Prateleira1() end
---FUNCTION LEFT OR RIGHT

-- PRIMEIRO ITEM DA PRATELEIRA
   local Window = "WindowPratileira1"
   local Name = "lunala"
   local Diamond = 12
   local PokeCoin = 24
   
   local Sex1 = "female" --Primeiro Icone de Sexo
   local Sex1Texto = "Feminino"
   -- local Sex1_Texto = "Masculino"
   
   local Sex2 = "male" --Segundo Icone de Sexo
   -- local Sex2_Texto = "Feminino"
   local Sex2Texto = "Masculino"

   promocaoPanel:getChildById(Window):getChildById("Comprar"):setImageSource('images/promocao/buttons/comprar_pratileira')
   promocaoPanel:getChildById(Window):getChildById("Comprar").onClick = function() BuzzBox() end
   
   promocaoPanel:getChildById(Window):show()
   promocaoPanel:getChildById(Window):setImageSource('images/promocao/pratileira/background/'..Name)
   promocaoPanel:getChildById(Window):getChildById("SlotItemPratileira"):setImageSource('images/promocao/pratileira/item/'..Name)
   
   promocaoPanel:getChildById(Window):getChildById("Star"):hide()
   promocaoPanel:getChildById(Window):getChildById("Star").tooltip = "Essa roupa possui a habilidade\nde TAUNT"
   
   promocaoPanel:getChildById(Window):getChildById("Sex1"):hide()
   promocaoPanel:getChildById(Window):getChildById("Sex1"):setImageSource('images/promocao/pratileira/'..Sex1)
   promocaoPanel:getChildById(Window):getChildById("Sex1").tooltip = Sex1Texto
   
   -- promocaoPanel:getChildById(Window):getChildById("Sex2"):show()
   promocaoPanel:getChildById(Window):getChildById("Sex2"):setImageSource('images/promocao/pratileira/'..Sex2)
   promocaoPanel:getChildById(Window):getChildById("Sex2").tooltip = Sex2Texto
   
   promocaoPanel:getChildById(Window):getChildById("Diamond"):setImageSource('images/count/diamond/'..Diamond)
   promocaoPanel:getChildById(Window):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..PokeCoin)
   promocaoPanel:getChildById(Window):getChildById("NameItem"):setImageSource('images/promocao/pratileira/name/'..Name)
-- PRIMEIRO ITEM DA PRATELEIRA
-- SEGUNDO ITEM DA PRATELEIRA
   local Window = "WindowPratileira2"
   local Name = "magikarp"
   local Diamond = 5
   local PokeCoin = 10
   
   local Sex1 = "male" --Primeiro Icone de Sexo
   -- local Sex1Texto = "Feminino"
   local Sex1_Texto = "Masculino"
   
   local Sex2 = "male" --Segundo Icone de Sexo
   -- local Sex2_Texto = "Feminino"
   local Sex2Texto = "Masculino"

   promocaoPanel:getChildById(Window):getChildById("Comprar"):setImageSource('images/promocao/buttons/comprar_pratileira')
   promocaoPanel:getChildById(Window):getChildById("Comprar").onClick = function() BuzzBox() end
   
   promocaoPanel:getChildById(Window):show()
   promocaoPanel:getChildById(Window):setImageSource('images/promocao/pratileira/background/'..Name)
   promocaoPanel:getChildById(Window):getChildById("SlotItemPratileira"):setImageSource('images/promocao/pratileira/item/'..Name)
   
   promocaoPanel:getChildById(Window):getChildById("Star"):hide()
   promocaoPanel:getChildById(Window):getChildById("Star").tooltip = "Essa roupa possui a habilidade\nde TAUNT"
   
   promocaoPanel:getChildById(Window):getChildById("Sex1"):hide()
   promocaoPanel:getChildById(Window):getChildById("Sex1"):setImageSource('images/promocao/pratileira/'..Sex1)
   promocaoPanel:getChildById(Window):getChildById("Sex1").tooltip = Sex1Texto
   
   -- promocaoPanel:getChildById(Window):getChildById("Sex2"):show()
   promocaoPanel:getChildById(Window):getChildById("Sex2"):setImageSource('images/promocao/pratileira/'..Sex2)
   promocaoPanel:getChildById(Window):getChildById("Sex2").tooltip = Sex2Texto
   
   promocaoPanel:getChildById(Window):getChildById("Diamond"):setImageSource('images/count/diamond/'..Diamond)
   promocaoPanel:getChildById(Window):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..PokeCoin)
   promocaoPanel:getChildById(Window):getChildById("NameItem"):setImageSource('images/promocao/pratileira/name/'..Name)
-- SEGUNDO ITEM DA PRATELEIRA
-- TERCEIRO ITEM DA PRATELEIRA
   local Window = "WindowPratileira3"
   local Name = "corsola"
   local Diamond = 5
   local PokeCoin = 10
   
   local Sex1 = "female" --Primeiro Icone de Sexo
   local Sex1Texto = "Feminino"
   -- local Sex1_Texto = "Masculino"
   
   local Sex2 = "male" --Segundo Icone de Sexo
   -- local Sex2_Texto = "Feminino"
   local Sex2Texto = "Masculino"

   promocaoPanel:getChildById(Window):getChildById("Comprar"):setImageSource('images/promocao/buttons/comprar_pratileira')
   promocaoPanel:getChildById(Window):getChildById("Comprar").onClick = function() BuzzBox() end
   
   promocaoPanel:getChildById(Window):show()
   promocaoPanel:getChildById(Window):setImageSource('images/promocao/pratileira/background/'..Name)
   promocaoPanel:getChildById(Window):getChildById("SlotItemPratileira"):setImageSource('images/promocao/pratileira/item/'..Name)
   
   promocaoPanel:getChildById(Window):getChildById("Star"):hide()
   promocaoPanel:getChildById(Window):getChildById("Star").tooltip = "Essa roupa possui a habilidade\nde TAUNT"
   
   promocaoPanel:getChildById(Window):getChildById("Sex1"):hide()
   promocaoPanel:getChildById(Window):getChildById("Sex1"):setImageSource('images/promocao/pratileira/'..Sex1)
   promocaoPanel:getChildById(Window):getChildById("Sex1").tooltip = Sex1Texto
   
   -- promocaoPanel:getChildById(Window):getChildById("Sex2"):show()
   promocaoPanel:getChildById(Window):getChildById("Sex2"):setImageSource('images/promocao/pratileira/'..Sex2)
   promocaoPanel:getChildById(Window):getChildById("Sex2").tooltip = Sex2Texto
   
   promocaoPanel:getChildById(Window):getChildById("Diamond"):setImageSource('images/count/diamond/'..Diamond)
   promocaoPanel:getChildById(Window):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..PokeCoin)
   promocaoPanel:getChildById(Window):getChildById("NameItem"):setImageSource('images/promocao/pratileira/name/'..Name)
-- TERCEIRO ITEM DA PRATELEIRA
-- QUARTO ITEM DA PRATELEIRA
   local Window = "WindowPratileira4"
   local Name = "popplio"
   local Diamond = 5
   local PokeCoin = 10
   
   local Sex1 = "male" --Primeiro Icone de Sexo
   -- local Sex1Texto = "Feminino"
   local Sex1_Texto = "Masculino"
   
   local Sex2 = "male" --Segundo Icone de Sexo
   -- local Sex2_Texto = "Feminino"
   local Sex2Texto = "Masculino"

   promocaoPanel:getChildById(Window):getChildById("Comprar"):setImageSource('images/promocao/buttons/comprar_pratileira')
   promocaoPanel:getChildById(Window):getChildById("Comprar").onClick = function() BuzzBox() end
   
   promocaoPanel:getChildById(Window):show()
   promocaoPanel:getChildById(Window):setImageSource('images/promocao/pratileira/background/'..Name)
   promocaoPanel:getChildById(Window):getChildById("SlotItemPratileira"):setImageSource('images/promocao/pratileira/item/'..Name)
   
   promocaoPanel:getChildById(Window):getChildById("Star"):hide()
   promocaoPanel:getChildById(Window):getChildById("Star").tooltip = "Essa roupa possui a habilidade\nde TAUNT"
   
   promocaoPanel:getChildById(Window):getChildById("Sex1"):hide()
   promocaoPanel:getChildById(Window):getChildById("Sex1"):setImageSource('images/promocao/pratileira/'..Sex1)
   promocaoPanel:getChildById(Window):getChildById("Sex1").tooltip = Sex1Texto
   
   -- promocaoPanel:getChildById(Window):getChildById("Sex2"):show()
   promocaoPanel:getChildById(Window):getChildById("Sex2"):setImageSource('images/promocao/pratileira/'..Sex2)
   promocaoPanel:getChildById(Window):getChildById("Sex2").tooltip = Sex2Texto
   
   promocaoPanel:getChildById(Window):getChildById("Diamond"):setImageSource('images/count/diamond/'..Diamond)
   promocaoPanel:getChildById(Window):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..PokeCoin)
   promocaoPanel:getChildById(Window):getChildById("NameItem"):setImageSource('images/promocao/pratileira/name/'..Name)
-- QUARTO ITEM DA PRATELEIRA
-- QUINTO ITEM DA PRATELEIRA
   local Window = "WindowPratileira5"
   local Name = "tonystark"
   local Diamond = 8
   local PokeCoin = 16
   
   local Sex1 = "male" --Primeiro Icone de Sexo
   -- local Sex1Texto = "Feminino"
   local Sex1_Texto = "Masculino"
   
   local Sex2 = "male" --Segundo Icone de Sexo
   -- local Sex2_Texto = "Feminino"
   local Sex2Texto = "Masculino"

   promocaoPanel:getChildById(Window):getChildById("Comprar"):setImageSource('images/promocao/buttons/comprar_pratileira')
   promocaoPanel:getChildById(Window):getChildById("Comprar").onClick = function() BuzzBox() end
   
   promocaoPanel:getChildById(Window):hide()
   promocaoPanel:getChildById(Window):setImageSource('images/promocao/pratileira/background/'..Name)
   promocaoPanel:getChildById(Window):getChildById("SlotItemPratileira"):setImageSource('images/promocao/pratileira/item/'..Name)
   
   -- promocaoPanel:getChildById(Window):getChildById("Star"):show()
   promocaoPanel:getChildById(Window):getChildById("Star").tooltip = "Essa roupa possui a habilidade\nde TAUNT"
   
   promocaoPanel:getChildById(Window):getChildById("Sex1"):show()
   promocaoPanel:getChildById(Window):getChildById("Sex1"):setImageSource('images/promocao/pratileira/'..Sex1)
   promocaoPanel:getChildById(Window):getChildById("Sex1").tooltip = Sex1Texto
   
   -- promocaoPanel:getChildById(Window):getChildById("Sex2"):show()
   promocaoPanel:getChildById(Window):getChildById("Sex2"):setImageSource('images/promocao/pratileira/'..Sex2)
   promocaoPanel:getChildById(Window):getChildById("Sex2").tooltip = Sex2Texto
   
   promocaoPanel:getChildById(Window):getChildById("Diamond"):setImageSource('images/count/diamond/'..Diamond)
   promocaoPanel:getChildById(Window):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..PokeCoin)
   promocaoPanel:getChildById(Window):getChildById("NameItem"):setImageSource('images/promocao/pratileira/name/'..Name)
-- QUINTO ITEM DA PRATELEIRA
-- SEXTO ITEM DA PRATELEIRA
   local Window = "WindowPratileira6"
   local Name = "hoho"
   local Diamond = 12
   local PokeCoin = 24
   
   local Sex1 = "female" --Primeiro Icone de Sexo
   local Sex1Texto = "Feminino"
   -- local Sex1_Texto = "Masculino"
   
   local Sex2 = "male" --Segundo Icone de Sexo
   -- local Sex2_Texto = "Feminino"
   local Sex2Texto = "Masculino"

   promocaoPanel:getChildById(Window):getChildById("Comprar"):setImageSource('images/promocao/buttons/comprar_pratileira')
   promocaoPanel:getChildById(Window):getChildById("Comprar").onClick = function() BuzzBox() end
   
   promocaoPanel:getChildById(Window):hide()
   promocaoPanel:getChildById(Window):setImageSource('images/promocao/pratileira/background/'..Name)
   promocaoPanel:getChildById(Window):getChildById("SlotItemPratileira"):setImageSource('images/promocao/pratileira/item/'..Name)
   
   -- promocaoPanel:getChildById(Window):getChildById("Star"):show()
   promocaoPanel:getChildById(Window):getChildById("Star").tooltip = "Essa roupa possui a habilidade\nde TAUNT"
   
   -- promocaoPanel:getChildById(Window):getChildById("Sex1"):show()
   promocaoPanel:getChildById(Window):getChildById("Sex1"):setImageSource('images/promocao/pratileira/'..Sex1)
   promocaoPanel:getChildById(Window):getChildById("Sex1").tooltip = Sex1Texto
   
   -- promocaoPanel:getChildById(Window):getChildById("Sex2"):show()
   promocaoPanel:getChildById(Window):getChildById("Sex2"):setImageSource('images/promocao/pratileira/'..Sex2)
   promocaoPanel:getChildById(Window):getChildById("Sex2").tooltip = Sex2Texto
   
   promocaoPanel:getChildById(Window):getChildById("Diamond"):setImageSource('images/count/diamond/'..Diamond)
   promocaoPanel:getChildById(Window):getChildById("PokeCoin"):setImageSource('images/count/gold_coin/'..PokeCoin)
   promocaoPanel:getChildById(Window):getChildById("NameItem"):setImageSource('images/promocao/pratileira/name/'..Name)
-- SEXTO ITEM DA PRATELEIRA
end